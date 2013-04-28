module ClusteringGeospatialVisualisationTechnique

  include GeospatialVisualisationTechnique

  private

  # Returns an array of GeoJSON::Feature for this layer.
  # Uses +options+ to define how to build a custom array of features.
  # +options+ include:
  #
  # [+:bbox+] a String representing a bbox "#{w}, #{s}, #{e}, #{n}"
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

  def _get_features(options)
    features = []

    raise ArgumentError, "Expected options to include :bbox -> #{options.inspect}" unless options.include?(:bbox)

    mappable_relation = mappables.in_rect(options[:bbox].split(','))

    cluster_result = mappable_relation.cluster(options)
    cluster_result.each do |cluster|
      geom_feature = Mappable.rgeo_factory_for_column(:geometry).parse_wkt(cluster.cluster_centroid)
      feature = RGeo::GeoJSON::Feature.new(geom_feature, nil, { cluster_size: cluster.cluster_geometry_count.to_i })

      features << feature
    end

    features
  end

end
