require 'test_helper'

class LayerTest < ActiveSupport::TestCase
  def setup
    @layer_one = layers(:one)
  end

  test "GeoJSON output for clustered points includes cluster_size property" do
    json = @layer_one.get_geo_json()

    feature_hash = json["features"].first
    cluster_size = feature_hash["properties"]["cluster_size"]
    assert_kind_of(
      Integer,
      cluster_size,
      "cluster_size property should have " +
      "been a kind of Integer. Instread it is: #{cluster_size.inspect}"
    )
    assert(
      (cluster_size >= 0), 
      "cluster_size property should have been greater than 0"
    )
  end
end
