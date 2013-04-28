module BasicGeospatialVisualisationTechnique

  include GeospatialVisualisationTechnique

  private

  # Returns an array of GeoJSON::Feature for this layer.
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
    mappable_relation = nil
    mappable_relation = mappables

    mappable_relation.each do |mappable|
      geom_feature = mappable.geometry
      feature = RGeo::GeoJSON::Feature.new(geom_feature, mappable.id, { cluster_size: 1 })
      features << feature
    end

    features
  end

end
