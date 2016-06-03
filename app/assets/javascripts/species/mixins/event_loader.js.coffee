Species.EventLoader = Ember.Mixin.create
  ensureEventsLoaded: (searchController) ->
    unless @controllerFor('events').get('loaded')
      @controllerFor('events').load()
