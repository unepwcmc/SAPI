Species.GeoEntityAutoCompleteLookup = Ember.Mixin.create
  geoEntityQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedGeoEntitiesIds: []

  geoEntityQueryObserver: ( ->
    removeDiactritics = (string) -> string.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

    query = removeDiactritics(@get('geoEntityQuery'));

    re = new RegExp("(^|\\(| )"+query,"i")
    @set 'autoCompleteCountries', @get('geoEntities.countries').filter (item, index, enumerable) =>
      re.test removeDiactritics(item.get('name'));

    re = new RegExp("^[0-9]- "+query,"i")
    @set 'autoCompleteRegions', @get('geoEntities.regions').filter (item, index, enumerable) =>
      re.test removeDiactritics(item.get('name'));
  ).observes('geoEntityQuery')

  geoEntitiesObserver: ( ->
    Ember.run.once(@, 'initForm')
  ).observes('geoEntities.@each.didLoad')

  initForm: ->
    @set 'selectedGeoEntities', @get('geoEntities.content').filter (geoEntity) =>
      return @get('selectedGeoEntitiesIds').indexOf(geoEntity.get('id')) >= 0
    @set('autoCompleteRegions', @get('geoEntities.regions'))
    @set('autoCompleteCountries', @get('geoEntities.countries'))

  actions:
    deleteGeoEntitySelection: (context) ->
      @get('selectedGeoEntities').removeObject(context)
