Species.IndexRoute = Ember.Route.extend

  setupController: ->
    geoEntitiesController = @controllerFor('geoEntities')
    geoEntitiesController.set('content', Species.GeoEntity.find())
  
    @controllerFor('higherTaxaCitesEu').set('content', 
      Species.TaxonConcept.find({
        taxonomy: 'cites_eu'
        ranks: ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
        autocomplete: true
      })
    )
    @controllerFor('higherTaxaCms').set('content', 
      Species.TaxonConcept.find({
        taxonomy: 'cms'
        ranks: ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
        autocomplete: true
      })
    )

  renderTemplate: ->
    # Render the `index` template into
    # the default outlet, and display the `index`
    # controller.
    @render('index', {
      into: 'application',
      outlet: 'main'
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

    @render('downloads', {
      into: 'application',
      outlet: 'downloads',
      controller: @controllerFor('downloads')
    })
    @render('downloadsButton', {
      into: 'index',
      outlet: 'downloadsButton',
      controller: @controllerFor('downloads')
    })
