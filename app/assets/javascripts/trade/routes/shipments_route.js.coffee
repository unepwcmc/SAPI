Trade.ShipmentsRoute = Ember.Route.extend Trade.QueryParams,

  beforeModel: ->
    (new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('geoEntities').load())
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('terms').set('content', Trade.Term.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('units').set('content', Trade.Unit.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('sources').set('content', Trade.Source.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('purposes').set('content', Trade.Purpose.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(Ember.run.sync())
    ))

  model: (params, queryParams, transition) ->
    # redo the array params if we're coming from the url
    @get('selectedQueryParamNames').forEach (property) ->
      if property.type == 'array' && queryParams[property.param] == true
        queryParams[property.param] = []
    if $.isEmptyObject(queryParams)
      Trade.Shipment.all().clear()
    else
      Trade.Shipment.find(queryParams)

  afterModel: (model, transition) ->
    # Resetting the default values in the form.
    controller = @controllerFor("shipments")
    unless controller.get('selectedTimeStart')
      timeStart = controller.get('defaultTimeStart')
      controller.set('selectedTimeStart', timeStart)
    unless controller.get('selectedTimeEnd')
      timeStart = controller.get('defaultTimeEnd')
      controller.set('selectedTimeEnd', timeStart)

