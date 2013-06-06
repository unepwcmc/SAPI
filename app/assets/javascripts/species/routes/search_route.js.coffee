Species.SearchRoute = Ember.Route.extend

  setupController: (controller, model) ->
    @controllerFor('taxonConcepts').set('content', Species.TaxonConcept.find model )

  renderTemplate: ->
    taxonConceptsController = @controllerFor('taxonConcepts')
    searchController = @controllerFor('search')
    # Render the `taxon_concepts` template into
    # the default outlet, and display the `taxonConcepts`
    # controller.
    @render('taxonConcepts', {
      into: 'application',
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

  serialize: (model) ->
    #TODO serialize this properly
    {params: '?taxonomy=' + model.taxonomy + '&scientific_name=' + model.scientific_name}
