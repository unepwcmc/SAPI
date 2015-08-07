Species.DocumentsRoute = Ember.Route.extend Species.Spinner,

  beforeModel: (queryParams, transition) ->
    @controllerFor('elibrarySearch').setFilters(queryParams)

  setupController: (controller, model) ->
    $.ajax(
      url: "/api/v1/documents?taxon_concept_id=4521",
      success: (data) ->
        controller.set('content', data)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
    )


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

  actions:
    ensureGeoEntitiesLoaded: ->
      @controllerFor('geoEntities').load()
