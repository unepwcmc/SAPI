Trade.SearchRoute = Trade.BeforeRoute.extend

  beforeModel: (params) ->
    Ember.RSVP.all([
      @controllerFor('geoEntities').load()
      @controllerFor('terms').load()
      @controllerFor('units').load()
      @controllerFor('sources').load()
      @controllerFor('purposes').load()
      @controllerFor('search').resetFilters()
    ])
