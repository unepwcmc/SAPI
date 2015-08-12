Species.GeoEntityLoader = Ember.Mixin.create
  ensureGeoEntitiesLoaded: (searchController) ->
    geoEntitiesLoaded = @controllerFor('geoEntities').get('loaded')
    if geoEntitiesLoaded
      searchController.initForm()
    else
      @controllerFor('geoEntities').load()
