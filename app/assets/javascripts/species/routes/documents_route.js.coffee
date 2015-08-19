Species.DocumentsRoute = Ember.Route.extend Species.Spinner,
  Species.GeoEntityLoader, Species.EventLoader,
  Species.DocumentTagLoader,

  beforeModel: (queryParams, transition) ->
    @ensureGeoEntitiesLoaded(@controllerFor('search'))
    @ensureEventsLoaded(@controllerFor('elibrarySearch'))
    @ensureDocumentTagsLoaded(@controllerFor('elibrarySearch'))
    #dirty hack to check if we have an array or comma separated string here
    if queryParams.geo_entities_ids && queryParams.geo_entities_ids.substring
      queryParams.geo_entities_ids = queryParams.geo_entities_ids.split(',')
    @controllerFor('elibrarySearch').setFilters(queryParams)
    $(@spinnerSelector).css("visibility", "visible")

  model: (params, queryParams, transition) ->
    controller = @controllerFor('documents')
    $.ajax(
      url: "/api/v1/documents",
      data: queryParams,
      success: (data) ->
        controller.set('content', data)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
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
