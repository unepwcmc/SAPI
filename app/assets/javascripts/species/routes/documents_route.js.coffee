Species.DocumentsRoute = Ember.Route.extend Species.Spinner,
  Species.GeoEntityLoader, Species.EventLoader,
  Species.DocumentTagLoader, Species.DocumentLoader,

  beforeModel: (transition) ->
    queryParams = transition.queryParams

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

  model: (params, transition) ->
    queryParams = params.queryParams

    @resetDocumentsResults()
    if queryParams['event_type']
      @loadDocumentsForEventType(queryParams['event_type'], queryParams)
    else
      @get('eventTypes').forEach((eventType) =>
        eventQueryParams = $.extend({}, queryParams, {event_type: eventType})

        @loadDocumentsForEventType(eventType, eventQueryParams)
      )

  afterModel: (model, transition) ->
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

  loadDocumentsForEventType: (eventType, eventQueryParams) ->
    eventType = @getEventTypeKey(eventType).camelize()
    controller = @controllerFor('documents')
    eventKey = eventType + 'Documents'
    isLoadingProperty = eventType + 'DocsIsLoading'

    controller.set(isLoadingProperty, true)
    @loadDocuments(eventQueryParams, (documents) =>      
      controller.set(eventKey, documents)
    )

  resetDocumentsResults: () ->
    controller = @controllerFor('documents')
    controller.set('euSrgDocuments', {})
    controller.set('citesCopProposalsDocuments', {})
    controller.set('citesAcDocuments', {})
    controller.set('citesPcDocuments', {})
    controller.set('idMaterialsDocuments', {})
    controller.set('otherDocuments', {})

  actions:
    queryParamsDidChange: (changed, totalPresent, removed) ->
      @refresh()