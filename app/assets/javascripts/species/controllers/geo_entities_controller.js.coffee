Species.GeoEntitiesController = Ember.ArrayController.extend
  content: null
  needs: ['search']
  regions: null
  countries: null

  contentObserver: ( ->
    Ember.run.once(@, 'initAutocompleteGeoEntities')
  ).observes("content.@each.didLoad")

  initAutocompleteGeoEntities: ->
    @set('regions', @get('content').filterProperty('geoEntityType', 'CITES_REGION'))
    @set('controllers.search.autoCompleteRegions', @get('regions'))
   	@set('countries', @get('content').filterProperty('geoEntityType', 'COUNTRY'))
   	@set('controllers.search.autoCompleteCountries', @get('countries'))