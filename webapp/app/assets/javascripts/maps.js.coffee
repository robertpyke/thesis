# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

map = null

# Lat/Lng
geographic = new OpenLayers.Projection("EPSG:4326");

# Spherical Meters
mercator = new OpenLayers.Projection("EPSG:900913");


world_bounds = new OpenLayers.Bounds();
world_bounds.extend(new OpenLayers.LonLat(-180,90));
world_bounds.extend(new OpenLayers.LonLat(180,-90));
# world_bounds = world_bounds.transform(geographic, mercator);

zoom_bounds = world_bounds;

setup_map = () ->
  # Clear away the old map
  if map
    map.destroy()

  map = new OpenLayers.Map('map', {
    maxExtent: world_bounds
  })

  layerSwitcher = new OpenLayers.Control.LayerSwitcher();
  map.addControl(layerSwitcher)

  osm_layer = new OpenLayers.Layer.OSM()
  map.addLayer(osm_layer)

  # Load the map's JSON data
  $map_tag = $('#map')
  map_url = $map_tag.data('url')
  map_layers_url = map_url + "/layers"

  # Load the layers associated with this map
  $.getJSON(map_layers_url, (layers_data) ->
    for layer in layers_data
      layer_name = layer["name"]
      layer_id = layer["id"]
      layer_url = map_layers_url + "/" + layer_id
      wkt_layer_url = layer_url + ".text"

      strategies = []

      # Use the bbox strategy if checked
      if $("#bbox:checked").length > 0
        strategies = [new OpenLayers.Strategy.BBOX({
          resFactor: 1.1
        })]
      else
        strategies = [new OpenLayers.Strategy.Fixed()]

      http_params = {}
      # Cluster if the cluster checkbox is checked
      if $("#cluster:checked").length > 0
        http_params["cluster"] = true

      wkt_layer = new OpenLayers.Layer.Vector(layer_name, {
          strategies: strategies
          protocol: new OpenLayers.Protocol.HTTP({
              url: wkt_layer_url
              format: new OpenLayers.Format.WKT()
              params: http_params
          })
      })

      map.addLayer(wkt_layer)
      map.zoomToMaxExtent()
  )


$ ->
  # Setup listeners
  $("#map_options input").bind('change', () ->
    setup_map()
  )

  # If this view has a map
  if document.getElementById 'map'
    setup_map()

