Species.GeoEntityAutoCompleteLookup = Ember.Mixin.create
  geoEntityQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedGeoEntitiesIds: []

  geoEntityQueryObserver: ( ->
    re = new RegExp("(^|\\(| )"+@get('geoEntityQuery'),"i")
    @set 'autoCompleteCountries', @get('geoEntities.countries').filter (item, index, enumerable) =>
      re.test item.get('name')

    re = new RegExp("^[0-9]- "+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('geoEntities.regions').filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  geoEntitiesObserver: ( ->
    Ember.run.once(@, 'initForm')
  ).observes('geoEntities.@each.didLoad')

  initForm: ->
    @set 'selectedGeoEntities', @get('geoEntities.content').filter (geoEntity) =>
      return geoEntity.get('id') of @get('selectedGeoEntitiesIds')
    @set('autoCompleteRegions', @get('geoEntities.regions'))
    @set('autoCompleteCountries', @get('geoEntities.countries'))

  actions:
    deleteGeoEntitySelection: (context) ->
      @get('selectedGeoEntities').removeObject(context)
