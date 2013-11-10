Species.TaxonConceptsRoute = Ember.Route.extend

  beforeModel: (queryParams, transition) ->
    @controllerFor('search').setFilters(queryParams)

  model: (params, queryParams, transition) ->
    queryParams.geo_entities_ids = [] if queryParams.geo_entities_ids == true
    Species.TaxonConcept.find(queryParams)

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
    ensureGeoEntitiesLoaded: ->
      @controllerFor('geoEntities').load()

    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()
