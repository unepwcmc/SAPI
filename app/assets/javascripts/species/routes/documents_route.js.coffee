Species.DocumentsRoute = Ember.Route.extend Species.Spinner,
  Species.GeoEntityLoader, Species.EventLoader,
  Species.DocumentTagLoader, Species.DocumentLoader,

  beforeModel: (queryParams, transition) ->
    @ensureGeoEntitiesLoaded(@controllerFor('search'))
    @ensureEventsLoaded(@controllerFor('elibrarySearch'))
    @ensureDocumentTagsLoaded(@controllerFor('elibrarySearch'))
    #dirty hack to check if we have an array or comma separated string here
    if queryParams.geo_entities_ids && queryParams.geo_entities_ids.substring
      queryParams.geo_entities_ids = queryParams.geo_entities_ids.split(',')
    if queryParams.events_ids && queryParams.events_ids.substring
      queryParams.events_ids = queryParams.events_ids.split(',')
    queryParams.geo_entities_ids = [] if queryParams.geo_entities_ids == true
    queryParams.events_ids = [] if queryParams.events_ids == true
    @controllerFor('elibrarySearch').setFilters(queryParams)
    $(@spinnerSelector).css("visibility", "visible")
    $('tr.group i.fa-minus-circle').click()

  model: (params, queryParams, transition) ->
    @resetDocumentsResults()
    if queryParams['event_type']
      @loadDocumentsForEventType(queryParams['event_type'], queryParams)
    else
      ['EcSrg', 'CitesCop', 'CitesAc,CitesTc', 'CitesPc', 'Other'].forEach((eventType) =>
        eventTypeQueryParams = {}
        $.extend(eventTypeQueryParams, queryParams, {event_type: eventType})
        @loadDocumentsForEventType(eventType, eventTypeQueryParams)
      )

  afterModel: (queryParams, transition) ->
    $(@spinnerSelector).css("visibility", "hidden")

  renderTemplate: ->
    # Render the `documents` template into
    # the default outlet, and display the `documents`
    # controller.
    @render('documents', {
      into: 'application',
      outlet: 'main',
      controller: @controllerFor('documents')
    })
    # Render the `elibrary_search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('elibrarySearchForm', {
      into: 'documents',
      outlet: 'search',
      controller: @controllerFor('elibrarySearch')
    })

  loadDocumentsForEventType: (eventType, eventTypeQueryParams) ->
    controller = @controllerFor('documents')
    eventTypeKey = @getEventTypeKey(eventType).camelize() + 'Documents'
    @loadDocuments(eventTypeQueryParams, (documents) =>
      controller.set(eventTypeKey, documents)
    )

  resetDocumentsResults: () ->
    controller = @controllerFor('documents')
    controller.set('euSrgDocuments', {})
    controller.set('citesCopProposalsDocuments', {})
    controller.set('citesAcDocuments', {})
    controller.set('citesPcDocuments', {})
    controller.set('otherDocuments', {})
