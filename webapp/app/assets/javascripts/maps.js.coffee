# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  # If this view has a map
  if document.getElementById 'map'
    map = new OpenLayers.Map 'map'
    layerSwitcher = new OpenLayers.Control.LayerSwitcher();
    map.addControl(layerSwitcher)

  #  wms_layer = new OpenLayers.Layer.WMS "OpenLayers WMS","http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'}
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

#        style_map = new OpenLayers.StyleMap({pointRadius: 10})
        wkt_layer = new OpenLayers.Layer.Vector(layer_name, {
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Protocol.HTTP({
                url: wkt_layer_url
                format: new OpenLayers.Format.WKT()
                params: {}
#                styleMap: style_map
            })
        })
        map.addLayer(wkt_layer)
        map.zoomToMaxExtent()
    )
