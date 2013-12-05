Trade.ShipmentsRoute = Ember.Route.extend

  beforeModel: ->
    @controllerFor('geoEntities').load()
    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())

  model: (params, queryParams, transition) ->
    queryParams.page = 1 unless queryParams.page
    Trade.Shipment.find(queryParams)
