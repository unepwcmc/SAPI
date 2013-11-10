Trade.ShipmentsRoute = Ember.Route.extend
  serialize: (model) ->
    {params: $.param(model)}

  beforeModel: ->
    @controllerFor('geoEntities').load()
    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())

  model: (params) ->
    # what follows here is the deserialisation of params
    # this hook is executed only when entering from url
    $.deparam(params.params)

  setupController: (controller, model) ->
    # this hook is executed whether entering from url or transition
    controller.setFilters(model)
    controller.set('content', Trade.Shipment.find(model))
