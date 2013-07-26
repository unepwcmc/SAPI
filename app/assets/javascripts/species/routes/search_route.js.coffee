Species.SearchRoute = Ember.Route.extend

  serialize: (model) ->
    {params: $.param(model)}

  model: (params) ->
    # what follows here is the deserialisation of params
    # this hook is executed only when entering from url
    $.deparam(params.params)

  setupController: (controller, model) ->
    # this hook is executed whether entering from url or transition
    controller.setFilters(model)
    @controllerFor('taxonConcepts').set('content', Species.TaxonConcept.find(model))

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

  events:
    ensureGeoEntitiesLoaded: ->
      @controllerFor('geoEntities').load()

    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()