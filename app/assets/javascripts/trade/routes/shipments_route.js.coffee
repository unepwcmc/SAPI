Trade.ShipmentsRoute = Ember.Route.extend Trade.QueryParams,

  beforeModel: ->

    @controllerFor('geoEntities').load()

    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())
    Ember.run.sync()

  model: (params, queryParams, transition) ->
    # redo the array params if we're coming from the url
    @get('selectedQueryParamNames').forEach (property) ->
      if property.type == 'array' && queryParams[property.param] == true
        queryParams[property.param] = []
    Trade.Shipment.find(queryParams)
