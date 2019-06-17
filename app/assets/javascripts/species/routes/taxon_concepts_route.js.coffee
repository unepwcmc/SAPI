Species.TaxonConceptsRoute = Ember.Route.extend Species.Spinner, Species.GeoEntityLoader,

  beforeModel: (transition) ->
    queryParams = transition.queryParams

    @ensureGeoEntitiesLoaded(@controllerFor('search'))
    #dirty hack to check if we have an array or comma separated string here
    if queryParams.geo_entities_ids && queryParams.geo_entities_ids.substring
      queryParams.geo_entities_ids = queryParams.geo_entities_ids.split(',')
    @controllerFor('search').setFilters(queryParams)
    # Setting a spinner until content is loaded.
    $(@spinnerSelector).css("visibility", "visible")

  model: (params, transition) ->
    queryParams = params.queryParams

    queryParams.geo_entities_ids = [] if queryParams.geo_entities_ids == true
    Species.TaxonConcept.find(queryParams)

  afterModel: (taxonConcepts, transition) ->
    if taxonConcepts.meta.total == 1
      @transitionTo('taxonConcept.legal', taxonConcepts.objectAt(0), queryParams: false)
    # Removing spinner once content is loaded.
    $(@spinnerSelector).css("visibility", "hidden")

  renderTemplate: ->
    taxonConceptsController = @controllerFor('taxonConcepts')
    searchController = @controllerFor('search')
    # Render the `taxon_concepts` template into
    # the default outlet, and display the `taxonConcepts`
    # controller.
    @render('taxonConcepts', {
      into: 'application',
      outlet: 'main',
      controller: taxonConceptsController
    })
    # Render the `search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('searchForm', {
      into: 'taxonConcepts',
      outlet: 'search',
      controller: searchController
    })

    @render('taxonConceptsResultsCount', {
      into: 'searchForm',
      outlet: 'count',
      controller: taxonConceptsController
    })

    @render('downloads', {
      into: 'application',
      outlet: 'downloads',
      controller: @controllerFor('downloads')
    })
    @render('downloadsButton', {
      into: 'downloads',
      outlet: 'downloadsButton',
      controller: @controllerFor('downloads')
    })

  actions:
    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()
    queryParamsDidChange: (changed, totalPresent, removed) ->
      @refresh()
