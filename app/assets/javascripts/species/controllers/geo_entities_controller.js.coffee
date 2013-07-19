Species.GeoEntitiesController = Ember.ArrayController.extend
  content: null
  regions: null
  countries: null

  contentObserver: ( ->
    Ember.run.once(@, 'initAutocompleteGeoEntities')
  ).observes("content.@each.didLoad")

  initAutocompleteGeoEntities: ->
    @set('regions', @get('content').filterProperty('geoEntityType', 'CITES_REGION'))
   	@set('countries', @get('content').filterProperty('geoEntityType', 'COUNTRY'))