Trade.ShipmentsRoute = Ember.Route.extend Trade.QueryParams,

  beforeModel: ->
    new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('geoEntities').load())
    )
    new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('terms').set('content', Trade.Term.find()))
    )
    new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('units').set('content', Trade.Unit.find()))
    )
    new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('sources').set('content', Trade.Source.find()))
    )
    new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('purposes').set('content', Trade.Purpose.find()))
    )
    Ember.run.sync()

  model: (params, queryParams, transition) ->
    # redo the array params if we're coming from the url
    @get('selectedQueryParamNames').forEach (property) ->
      if property.type == 'array' && queryParams[property.param] == true
        queryParams[property.param] = []
    Trade.Shipment.find(queryParams)
