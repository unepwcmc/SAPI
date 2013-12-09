Trade.GeoEntitiesController = Ember.ArrayController.extend
  content: null
  loaded: false

  contentObserver: ( ->
    @set('loaded', true)
  ).observes("content.@each.didLoad")

  load: ->
    unless @get('loaded')
      @set('content', Trade.GeoEntity.find({
      	geo_entity_types: ['COUNTRY', 'TERRITORY']
      }))