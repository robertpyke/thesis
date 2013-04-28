module GeospatialVisualisationTechniqueProxy

  @@techniques = [
    BasicGeospatialVisualisationTechnique,
    BoundingGeospatialVisualisationTechnique,
    ClusteringGeospatialVisualisationTechnique
  ]
  @@techniques.each do |technique|
    include technique
  end

  include GeospatialVisualisationTechnique

  def determine_visualisation_technique options
    if options.include?(:geospatial_visualisation_technique)
      tech = options[:geospatial_visualisation_technique]
      selected = @@techniques.select { |technique| technique.to_s == tech }
      technique = selected.first
      raise ArgumentError, "Invalid geospatial_visualisation_technique. Expected " + 
        "one of #{@@techniques.inspect}, was given: #{tech.inspect}" if technique.nil?
      technique
    else
      raise ArgumentError, "No geospatial_visualisation_technique specified. Expected " + 
        "one of #{@@techniques.inspect}"
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

  def _get_features(options)
    technique = determine_visualisation_technique(options)
    technique.instance_method(:_get_features).bind(self).call(options)
  end

end
