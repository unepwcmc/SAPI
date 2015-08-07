Species.TaxonConceptRoute = Ember.Route.extend Species.Spinner, Species.GeoEntityLoader,

  beforeModel: ->
    @ensureGeoEntitiesLoaded(@controllerFor('search'))
    # Setting a spinner until content is loaded.
    $(@spinnerSelector).css("visibility", "visible")

  model: (params) ->
    Species.TaxonConcept.find(params.taxon_concept_id)

  afterModel: (model) ->
    # The `citesListings` field is a proxy for the model completeness.
    if model.get('citesListings') == undefined
      model.reload()
    # Removing spinner once content is loaded.
    $(@spinnerSelector).css("visibility", "hidden")

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

  actions:
    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()
