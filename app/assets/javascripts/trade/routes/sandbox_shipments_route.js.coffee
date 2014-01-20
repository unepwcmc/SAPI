Trade.SandboxShipmentsRoute = Ember.Route.extend
  
  model: (params, queryParams, transition) ->
    Trade.SandboxShipment.find(queryParams)

  setupController: (controller, model, queryParams) ->
    controller.set('model', model)
    controller.set('errorParams', queryParams)

