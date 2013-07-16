Species.IndexRoute = Ember.Route.extend

  setupController: ->
    geoEntitiesController = @controllerFor('geoEntities')
    geoEntitiesController.set('content', Species.GeoEntity.find())

  renderTemplate: ->
    # Render the `index` template into
    # the default outlet, and display the `index`
    # controller.
    @render('index', {
      into: 'application',
      controller: @controllerFor('index')
    })
    # Render the `search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('searchForm', {
      into: 'index',
      outlet: 'search',
      controller: @controllerFor('search')
    })
