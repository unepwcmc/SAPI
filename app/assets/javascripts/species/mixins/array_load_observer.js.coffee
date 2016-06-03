Species.ArrayLoadObserver = Ember.Mixin.create
  loaded: false

  contentObserver: ( ->
    @set('loaded', true)
    Ember.run.once(@, 'handleLoadFinished')
  ).observes("content.@each.didLoad")