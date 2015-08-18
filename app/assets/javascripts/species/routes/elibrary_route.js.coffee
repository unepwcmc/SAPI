Species.ElibraryRoute = Ember.Route.extend Species.GeoEntityLoader,

  beforeModel: () ->
    @ensureGeoEntitiesLoaded(@controllerFor('elibrarySearch'))
    @controllerFor('events').set('content', Species.Event.find())

  renderTemplate: ->
    # Render the `index` template into
    # the default outlet, and display the `elibrary`
    # controller.
    @render('index', {
      into: 'application',
      outlet: 'main',
      controller: @controllerFor('elibrary')
    })
    # Render the `elibrary_search_form` template into
    # the outlet `search`, and display the `elibrary_search`
    # controller.
    @render('elibrarySearchForm', {
      into: 'index',
      outlet: 'search',
      controller: @controllerFor('elibrarySearch')
    })
