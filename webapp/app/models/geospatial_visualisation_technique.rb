module GeospatialVisualisationTechnique

  def get_features(options)
    start_t = Time.now
    features = _get_features(options)
    end_t = Time.now
    took_t = end_t - start_t

    Rails.logger.info("Time took to get features: #{took_t}s")
    return features
  end

  protected

  def _get_features(options)
    raise NotImplementedError, "get_features is not implemented for this visualisation technique"
  end
end
