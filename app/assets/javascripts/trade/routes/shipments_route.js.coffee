Trade.ShipmentsRoute = Ember.Route.extend Trade.QueryParams,

  beforeModel: ->
    @controllerFor('geoEntities').load()
    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())

  model: (params, queryParams, transition) ->
    queryParams.page = 1 unless queryParams.page
    # TODO: what about all the other params?
    Trade.Shipment.find(queryParams)
