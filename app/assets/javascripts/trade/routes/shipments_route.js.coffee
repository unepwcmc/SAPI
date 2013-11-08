Trade.ShipmentsRoute = Ember.Route.extend
  model: (params, queryParams, transition) ->
    return unless queryParams.page
    Trade.Shipment.find(queryParams)
