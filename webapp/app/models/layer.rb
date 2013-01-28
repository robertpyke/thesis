class LayerDataFileValidator < ActiveModel::Validator
  require 'csv'

  def validate(layer)
    if layer.data_file.file?
      csv_file = File.new(layer.data_file.queued_for_write[:original].path)
      csv_rows = CSV.read(csv_file)

      header_row = csv_rows[0]
      content_rows = csv_rows[1..-1]

      lat_pos = nil
      lng_pos = nil

      header_row.each_with_index do |el, i|
        case el.chomp.downcase
        when 'lat', 'latitude'
          lat_pos = i
        when 'lng', 'longitude'
          lng_pos = i
        # else the column is a descriptor
        end
      end

      if lat_pos.nil? or lng_pos.nil?
        layer.errors[:data_file] << "This data file doesn't contain " +
          "latitude and longitude columns"
      end
    end
  end
end

class Layer < ActiveRecord::Base
  belongs_to :map
  has_many :mappables, dependent: :destroy

  attr_accessible :name, :data_file

  has_attached_file :data_file

  validates_attachment :data_file, presence: true,
    content_type: { content_type: [ "text", "text/csv", "text/plain"] }

  # Validate the CSV file as having a single valid geometry column
  validates_with LayerDataFileValidator
  # Push the CSV contents into our DB
  before_save :process_data_file

  # Process our assocaited data file
  def process_data_file

    # Clear out the existing mappable entries
    mappables.clear

    # Add the new mappable entries
    csv_file = File.new(data_file.queued_for_write[:original].path)
    csv_rows = CSV.read(csv_file)

    header_row = csv_rows[0]
    content_rows = csv_rows[1..-1]

    lat_pos = nil
    lng_pos = nil

    header_row.each_with_index do |el, i|
      case el.chomp.downcase
      when 'lat', 'latitude'
        lat_pos = i
      when 'lng', 'longitude'
        lng_pos = i
      # else the column is a descriptor
      end
    end

    if lat_pos.nil? or lng_pos.nil?
      layer.errors[:data_file] << "This data file doesn't contain " +
        "latitude and longitude columns"
    end

    # iterate over the content rows
    content_rows.each do |content_row|
      lat = nil
      lng = nil
      geometry_point = nil
      descriptors = {}
      content_row.each_with_index do |el, i|
        if i == lat_pos
          lat = el
        elsif i == lng_pos
          lng = el
        else
          descriptor_label = header_row[i]
          descriptor_value = el
          descriptors[descriptor_label] = descriptor_value
        end
      end

      geometry_point = Mappable.rgeo_factory_for_column(:geometry).point(lng, lat)

      mappable = mappables.build
      mappable.geometry = geometry_point
      descriptors.each_pair do |label, value|
        descriptor = mappable.descriptors.build({ label: label, value: value})
      end
    end

    true
  end

  def get_geo_json(options={})
    geoms = []
    if options[:bbox]
      bbox_mappables = mappables.in_rect(options[:bbox].split(','))
      bbox_mappables.each do |mappable|
        geoms << mappable.geometry
      end
    else
      mappables.each do |mappable|
        geoms << mappable.geometry
      end
    end

    feature_collection = Mappable.rgeo_factory_for_column(:geometry).collection(geoms)
    RGeo::GeoJSON.encode(feature_collection)
  end

  def get_wkt(options={})
    geoms = []
    if options[:bbox]
      bbox_mappables = mappables.in_rect(options[:bbox].split(','))
      bbox_mappables.each do |mappable|
        geoms << mappable.geometry
      end
    else
      mappables.each do |mappable|
        geoms << mappable.geometry
      end
    end

    feature_collection = Mappable.rgeo_factory_for_column(:geometry).collection(geoms)
    feature_collection.as_text
  end

end
