Species.GeoEntitiesController = Ember.ArrayController.extend
  content: null
  regions: null
  countries: null
  loaded: false

  contentObserver: ( ->
    @set('loaded', true)
    Ember.run.once(@, 'initAutocompleteGeoEntities')
  ).observes("content.@each.didLoad")

  initAutocompleteGeoEntities: ->
    @set('regions', @get('content').filterProperty('geoEntityType', 'CITES_REGION'))
   	@set('countries', @get('content').filterProperty('geoEntityType', 'COUNTRY'))

  load: ->
    unless @get('loaded')
      @set('content', Species.GeoEntity.find({geo_entity_types: ['CITES_REGION', 'COUNTRY']}))