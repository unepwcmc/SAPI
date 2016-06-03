Species.GeoEntitiesController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  content: null
  regions: null
  countries: null

  load: ->
    unless @get('loaded')
      @set('content', Species.GeoEntity.find({geo_entity_types_set: 3}))

  handleLoadFinished: () ->
    @set('regions', @get('content').filterProperty('geoEntityType', 'CITES_REGION'))
    @set('countries', @get('content').filter((item, index, enumerable) ->
      return item.get('geoEntityType') == 'COUNTRY' || item.get('geoEntityType') == 'TERRITORY'
    ))