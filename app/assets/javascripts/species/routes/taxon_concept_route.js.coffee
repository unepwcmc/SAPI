Species.TaxonConceptRoute = Ember.Route.extend

  model: (params) ->
    Species.TaxonConcept.find(params.taxon_concept_id)
    

  setupController: (controller, model) ->
    # Call _super for default behavior (as of rc4)
    this._super(controller, model)
    # If the route is reached using a {{#linkTo route myObject}} or
    # transitionTo(myObject) call then the passed object is used to call
    # setupController directly and model is not called.
    # We might need to revisit this when loading particular tabs.

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
