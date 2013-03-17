class LayerAttachedFileValidator < ActiveModel::Validator

  def validate(layer)
    if layer.csv_file.present? and layer.renderable_file.present?
      layer.errors[:base] << "This layer has multiple attached files. It should " +
                             "only have renderable_file or a csv_file."
    elsif not layer.csv_file.present? and not layer.renderable_file.present?
      layer.errors[:base] << "This layer doesn't have any attached files."
    end
  end

end

class LayerCSVFileValidator < ActiveModel::Validator
  require 'csv'

  def validate(layer)
    if layer.csv_file.present?
      csv_file_f = File.new(layer.csv_file.queued_for_write[:original].path)
      csv_rows = CSV.read(csv_file_f)

      header_row = csv_rows[0]
      content_rows = csv_rows[1..-1]

      geometry_index_to_type = Layer.get_geometry_index_to_type_hash(header_row)
      geometry_types = geometry_index_to_type.values.uniq

      if geometry_types.include?(:latitude) and geometry_types.include?(:longitude)
        # all good
      else
        layer.errors[:csv_file] << "doesn't contain " +
          "latitude and longitude columns"
      end
    end
  end

end

class Layer < ActiveRecord::Base

  # The maximum number of features to return from a query
  FEATURES_QUERY_LIMIT = 1000

  belongs_to :map
  has_many :mappables, dependent: :destroy

  attr_accessible :name, :csv_file, :renderable_file

  has_attached_file :csv_file
  has_attached_file :renderable_file

#  validates_attachment :csv_file,
#    content_type: { content_type: [ "text", "text/csv", "text/plain", "text/comma-separated-values", "application/csv", "application/excel", "text/anytext"] }

#  validates_attachment :renderable_file, 
#    content_type: { content_type: [ "text", "text/asc", "text/plain"] }
  before_validation :clear_old_attachments

  # Validate the CSV file as having a single valid geometry column
  validates_with LayerAttachedFileValidator
  validates_with LayerCSVFileValidator

  # Check that we have a single attached file, and process the attached file
  before_save :process_attached_file

  # Searches the +csv_row_as_array_of_columns+ for geometry keywords.
  # Geometry keywords include:
  # * _latitude_  / _lat_
  # * _longitude_ / _lng_
  #
  # Returns a hash of index to geometry type.
  # Geometry types include:
  #
  # * +:latitude+
  # * +:longitude+

  def self.get_geometry_index_to_type_hash csv_row_as_array_of_columns
    geometry_index_to_type = {}
    csv_row_as_array_of_columns.each_with_index do |el, i|
      case el.chomp.downcase
      when 'lat', 'latitude'
        geometry_index_to_type[i] = :latitude
      when 'lng', 'longitude'
        geometry_index_to_type[i] = :longitude
      # else the column is a descriptor
      end
    end
    geometry_index_to_type
  end

  # Given a hash of geometry_data, and a hash of descriptors, builds
  # a mappable for this layer

  def build_mappable geometry_data, descriptors
      geometry = nil
      if lat=geometry_data[:latitude] and lng=geometry_data[:longitude]
        geometry = Mappable.rgeo_factory_for_column(:geometry).point(lng, lat)
      else
        raise NotImplementedError, "This geometry data (#{geometry_data.inspect}) is not yet supported"
      end

      mappable = mappables.build
      mappable.geometry = geometry
      descriptors.each_pair do |label, value|
        descriptor = mappable.descriptors.build({ label: label, value: value})
      end
      mappable
  end

  # Process our associated data file
  # Clears out any existing +mappables+
  # Generates new +mappables+ based on contents of data file

  def process_attached_file
    mappables.clear
    if csv_file.present?
      # Clear out the existing mappable entries
      process_csv_file
    elsif renderable_file.present?
      process_renderable_file
    end
  end


  # Returns an array of GeoJSON::Feature for this layer.
  # Uses +options+ to define how to build a custom array of features.
  # +options+ include:
  #
  # [+:bbox+] a String representing a bbox "#{w}, #{s}, #{e}, #{n}"
  # [+:cluster+] +!nil+ if you want the features to be clustered
  # [+:grid_size+] a Float representing the size of the clusters (lat/lng degrees decimal)
  #
  # The size of the array returned is limited by +FEATURES_QUERY_LIMIT+
  # regardless of options
  #
  # Note: The GeoJSON::Feature object type is used as a convenience wrapper to
  # allow the geometry to be provided with additional information (properties and feature_id).
  # The underlying geometry can be attained via the GeoJSON::Feature instance
  # function geometry().
  #
  # *Important*: The GeoJSON::Feature is a wrapper. It isn't the same as RGeo::Feature::Geometry.
  # You should _peel back_ the wrapper if you intend to use the feature for anything
  # other than GeoJSON encoding. You can _peel back_ the wrapper via the GeoJSON::Feature
  # instance function +geometry()+.

  def get_features(options)
    features = []
    mappable_relation = nil
    if options[:bbox]
      mappable_relation = mappables.in_rect(options[:bbox].split(','))
    else
      mappable_relation = mappables
    end

    if options[:cluster]
      cluster_result = nil
      cluster_result = mappable_relation.cluster(options)
      cluster_result.limit(FEATURES_QUERY_LIMIT).each do |cluster|
        geom_feature = Mappable.rgeo_factory_for_column(:geometry).parse_wkt(cluster.cluster_centroid)
        feature = RGeo::GeoJSON::Feature.new(geom_feature, nil, { cluster_size: cluster.cluster_geometry_count.to_i })

        features << feature
      end
    else
      mappable_relation.limit(FEATURES_QUERY_LIMIT).each do |mappable|
        geom_feature = mappable.geometry
        feature = RGeo::GeoJSON::Feature.new(geom_feature, mappable.id, { cluster_size: 1 })
        features << feature
      end
    end

    features
  end

  # Returns the layer's +mappables+ as a GeometryCollection
  # in *GeoJSON* (+String+)

  def get_geo_json(options={})
    features = get_features(options)
    feature_collection = RGeo::GeoJSON::FeatureCollection.new(features)
    RGeo::GeoJSON.encode(feature_collection)
  end

  # Returns the layer's +mappables+ as a GeometryCollection in *WKT* (+String+)

  def get_wkt(options={})
    features = get_features(options)
    geoms = features.map { |feature| feature.geometry() }
    feature_collection = Mappable.rgeo_factory_for_column(:geometry).collection(geoms)
    feature_collection.as_text
  end

  private

  # Removes the attachment that isn't changing
  #
  # i.e. if the user uploads a CSV for the layer, the renderable file is removed.
  # if the user uploads a renderable file for the layer, the CSV is removed.

  def clear_old_attachments
    if csv_file_updated_at_changed? and not renderable_file_updated_at_changed?
      renderable_file.clear
    elsif renderable_file_updated_at_changed? and not csv_file_updated_at_changed?
      csv_file.clear
    end

    true
  end


  # Process the attached data file as an ascii grid file

  def process_renderable_file
    true
  end

  # Process the attached data file as a CSV file

  def process_csv_file

    # Add the new mappable entries
    csv_file_f = File.new(csv_file.queued_for_write[:original].path)
    csv_rows = CSV.read(csv_file_f)

    header_row = csv_rows[0]
    content_rows = csv_rows[1..-1]

    # Create a Hash of the geometry indeces
    # i -> :geometry_type
    geometry_index_to_type = Layer.get_geometry_index_to_type_hash(header_row)

    # iterate over the content rows
    content_rows.each do |content_row|
      geometry_data = {}
      descriptors = {}

      content_row.each_with_index do |el, i|
        is_geom = false

        # Process the column in a special manner if it is a geometry column
        if geometry_type = geometry_index_to_type[i]
          geometry_data[geometry_type] = el
        else
          descriptor_label = header_row[i]
          descriptor_value = el
          descriptors[descriptor_label] = descriptor_value
        end
      end

      mappable = build_mappable(geometry_data, descriptors)
    end

    true
  end

end
