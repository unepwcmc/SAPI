Trade.SandboxShipmentsRoute = Ember.Route.extend
  
  model: () ->
    Trade.SandboxShipment.find({'appendix': 'I'})

