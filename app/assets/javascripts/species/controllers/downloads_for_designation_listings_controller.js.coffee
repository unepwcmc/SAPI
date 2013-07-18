Species.DownloadsForDesignationListingsController = Ember.Controller.extend
  designation: 'cites'
  appendices: ['I', 'II', 'III']

  needs: ['geoEntities']


  selectedAppendices: []
  geoEntityQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedGeoEntitiesIds: []
  selectedTaxonConcepts: []

  geoEntityOueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  geoEntityOueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  regionsObserver: ( ->
    @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
  ).observes('controllers.geoEntities.regions.@each.didLoad')

  countriesObserver: ( ->
    @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))
  ).observes('controllers.geoEntities.countries.@each.didLoad')

  selectedGeoEntitiesObserver: ( ->
    @set 'selectedGeoEntitiesIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')

  toParams: ( ->
    {
      data_type: 'Listings'
      filters: 
        designation: @get('designation')
        appendices: @get('selectedAppendices')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
    }
  ).property('selectedAppendices.@each', 'selectedGeoEntitiesIds.@each')

  downloadUrl: ( ->
    '/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')

Species.DownloadsForCitesListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'cites'
  appendices: ['I', 'II', 'III']

Species.DownloadsForEuListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'eu'
  appendices: ['A', 'B', 'C', 'D']

Species.DownloadsForCmsListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'cms'
  appendices: ['I', 'II']