Trade.SandboxShipmentsRoute = Ember.Route.extend
  
  model: (params, queryParams, transition) ->
    Trade.SandboxShipment.find(queryParams)

