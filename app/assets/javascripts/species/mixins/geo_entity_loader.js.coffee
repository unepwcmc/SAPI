Species.GeoEntityLoader = Ember.Mixin.create
  ensureGeoEntitiesLoaded: (searchController) ->
    geoEntitiesLoaded = searchController.get('geoEntities.loaded')
    if geoEntitiesLoaded
      searchController.initForm()
    else
      searchController.get('geoEntities').load()
