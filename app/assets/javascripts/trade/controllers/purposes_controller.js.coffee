Trade.PurposesController = Ember.ArrayController.extend
  content: null
  loaded: false

  contentObserver: ( ->
    @set('loaded', true)
  ).observes("content.@each.didLoad")

  load: ->
    unless @get('loaded')
      @set('content', Trade.Purpose.find())
