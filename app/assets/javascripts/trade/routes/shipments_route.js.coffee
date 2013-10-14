Trade.ShipmentsRoute = Ember.Route.extend
  serialize: (model) ->
    {params: $.param(model)}

  model: (params) ->
    # what follows here is the deserialisation of params
    # this hook is executed only when entering from url
    $.deparam(params.params)

  setupController: (controller, model) ->
    # this hook is executed whether entering from url or transition
    controller.setFilters(model)
    controller.set('content', Trade.Shipment.find(model))
