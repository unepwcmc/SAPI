Species.IndexRoute = Ember.Route.extend

  setupController: ->
    geoEntitiesController = @controllerFor('geoEntities')
    geoEntitiesController.set('content', Species.GeoEntity.find())

  renderTemplate: ->
    indexController = @controllerFor('index')
    searchController = @controllerFor('search')

    # Render the `index` template into
    # the default outlet, and display the `index`
    # controller.
    @render('index', {
      into: 'application',
      controller: indexController
    })
    # Render the `search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('searchForm', {
      into: 'index',
      outlet: 'search',
      controller: searchController
    })
