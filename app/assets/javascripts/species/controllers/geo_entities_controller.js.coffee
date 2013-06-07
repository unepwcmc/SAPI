Species.GeoEntitiesController = Ember.ArrayController.extend
  content: null
  needs: ['search']

  contentObserver: ( ->
    Ember.run.once(@, 'initAutocompleteGeoEntities')
  ).observes("content.@each.didLoad")

  initAutocompleteGeoEntities: ->
    @set('controllers.search.autoCompleteRegions', @get('content').filterProperty('geoEntityType', 'CITES_REGION'))
   	@set('controllers.search.autoCompleteCountries', @get('content').filterProperty('geoEntityType', 'COUNTRY'))