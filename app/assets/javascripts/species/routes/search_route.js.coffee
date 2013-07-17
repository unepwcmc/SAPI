Species.SearchRoute = Ember.Route.extend

  serialize: (model) ->
    {params: '?' + $.param(model)}

  model: (params) ->
    geoEntitiesController = @controllerFor('geoEntities')
    geoEntitiesController.set('content', Species.GeoEntity.find())
    # what follows here is the deserialisation of params
    # this hook is executed only when entering from url
    queryString = params.params
    #remove the questionmark
    if queryString[0] == '?'
      queryString = queryString.slice(1,queryString.length)
    params = $.deparam(queryString)
    params

  setupController: (controller, model) ->
    # this hook is executed whether entering from url or transition
    controller.setFilters(model)
    @controllerFor('taxonConcepts').set('content', Species.TaxonConcept.find(model))

  renderTemplate: ->
    console.log('render')
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
