Species.TaxonConceptRoute = Ember.Route.extend

  model: (params) ->
    Species.TaxonConcept.find(params.taxon_concept_id)

  renderTemplate: ->
    taxonConceptController = @controllerFor('taxonConcept')
    searchController = @controllerFor('search')
    # Render the `taxon_concept` template into
    # the default outlet, and display the `taxonConcept`
    # controller.
    @render('taxonConcept', {
      into: 'application',
      outlet: 'main',
      controller: taxonConceptController
    })
    # Render the `search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('searchForm', {
      into: 'taxonConcept',
      outlet: 'search',
      controller: searchController
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

  events:
    ensureGeoEntitiesLoaded: ->
      @controllerFor('geoEntities').load()

    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()

  # When the route is activated, reload the data. Hummmm...
  activate: ->
    @modelFor('taxonConcept').reload()
