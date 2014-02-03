Trade.ShipmentsRoute = Ember.Route.extend Trade.QueryParams,

  beforeModel: ->
    Ember.RSVP.all([
      @controllerFor('geoEntities').load()
      @controllerFor('terms').load()
      @controllerFor('units').load()
      @controllerFor('sources').load()
      @controllerFor('purposes').load()
    ])

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

