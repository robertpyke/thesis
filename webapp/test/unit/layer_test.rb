require 'test_helper'

class LayerTest < ActiveSupport::TestCase
  def get_csv_file
    fixture_file_upload "sample_layer_data.csv", "text/csv"
  end

  def get_asc_file
    fixture_file_upload "sample_ascii_grid.asc", "text/asc"
  end

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

  test "Shouldn't be able to save a layer with both kinds of attachment" do
    layer_hash = {
      name: "test file",
      csv_file: get_csv_file,
      renderable_file: get_asc_file
    }
    layer_x = Layer.new(layer_hash)
    assert !layer_x.save
  end

  test "Should be able to generate layer image from renderable_file attachment" do
    layer_hash = {
      name: "test file",
      renderable_file: get_asc_file
    }
    layer_x = Layer.new(layer_hash)
    assert layer_x.save

    map_file_path = File.join(Rails.root, 'lib', 'assets', 'test.map')
    map = Mapscript::MapObj.new(map_file_path)
    map.setExtent(115, -50, 160, -10)
    map.setSize(1024,1024)

    layer = map.layers.first
    layer.data = layer_x.renderable_file.path
    mapimage = map.draw

    FileUtils.mkdir_p(File.join(Rails.root, 'test', 'outputs'))
    mapimage.save(File.join(Rails.root, 'test', 'outputs', 'test.png'))
  end

  test "Should be able to generate layer image from renderable_file attachment with wms request params" do
    layer_hash = {
      name: "test file",
      renderable_file: get_asc_file
    }
    layer_x = Layer.new(layer_hash)
    assert layer_x.save

    #map = Mapscript::MapObj.new('test.map')
    map_file_path = File.join(Rails.root, 'lib', 'assets', 'test.map')
    map = Mapscript::MapObj.new(map_file_path)

    wms_request = Mapscript::OWSRequest.new()
    wms_request.setParameter("MODE", "map")
    wms_request.setParameter("SRS", "EPSG:4326")
    wms_request.setParameter("FORMAT", "image/png")
    wms_request.setParameter("SERVICE", "WMS")
    wms_request.setParameter("REQUEST", "GetMap")
    wms_request.setParameter("WIDTH", "100")
    wms_request.setParameter("HEIGHT", "100")
    wms_request.setParameter("BBOX", "115,-50,160,-10")
    wms_request.setParameter("LAYERS", "DEFAULT")
    map.loadOWSParameters(wms_request)

    layer = map.layers.first
    layer.data = layer_x.renderable_file.path
    mapimage = map.draw

    FileUtils.mkdir_p(File.join(Rails.root, 'test', 'outputs'))
    mapimage.save(File.join(Rails.root, 'test', 'outputs', 'test_with_wms_req_params.png'))
  end
end
