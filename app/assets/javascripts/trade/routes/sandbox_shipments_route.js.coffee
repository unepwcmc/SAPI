Trade.SandboxShipmentsRoute = Ember.Route.extend
  
  model: () ->
    Trade.SandboxShipment.find({'query_params_to_come': 'nothing'})
    