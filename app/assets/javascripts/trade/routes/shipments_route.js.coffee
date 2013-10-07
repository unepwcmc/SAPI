Trade.ShipmentsRoute = Ember.Route.extend
  model: () ->
    Trade.Shipment.find()
