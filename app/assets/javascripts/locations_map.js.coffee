window.Yumster or= {}
window.Yumster.MarkerSprite or= {}
window.Yumster.GoogleMaker or= {}
window.Yumster.Locations or= {}
window.Yumster.LocationManager or= {}
window.Yumster.Locations.Near or= {}
window.Yumster.Locations.Map or= {}

class LocationsMap

  constructor: () ->
    @gm = window.Yumster.GoogleMaker

  setMap: (map) ->
    window.Yumster.Locations.Map.map = map

  fitMapToBounds: (lat, lng, span) ->
    bounds = @gm.makeLatLngBounds()
    ne = @gm.makeLatLng lat + span / 2, lng + span / 2
    bounds.extend ne
    sw = @gm.makeLatLng lat - span / 2, lng - span / 2
    bounds.extend sw
    window.Yumster.Locations.Map.map.fitBounds(bounds)

$ ->
  window.Yumster.Locations.Map = new LocationsMap
  window.Yumster.Locations._Map = LocationsMap
