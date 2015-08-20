Species.EventLoader = Ember.Mixin.create
  ensureEventsLoaded: (searchController) ->
    if @controllerFor('events').get('loaded')
      searchController.initEventSelector()
    else
      @controllerFor('events').load()
