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
  autoCompleteTaxonConcepts: []
  selectedTaxonConcepts: []
  selectedTaxonConceptsIds: []

  geoEntityOueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  taxonConceptOueryObserver: ( ->
    re = new RegExp("^"+@get('taxonConceptQuery'),"i")

    @set 'autoCompleteTaxonConcepts', @get('higherTaxaController.content')
    .filter (item, index, enumerable) =>
      re.test item.get('fullName')
  ).observes('taxonConceptQuery')

  regionsObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
    )
  ).observes('controllers.geoEntities.regions.@each.didLoad')

  countriesObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))
    )
  ).observes('controllers.geoEntities.countries.@each.didLoad')

  higherTaxaObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteTaxonConcepts', @get('higherTaxaController.content'))
    )
  ).observes('higherTaxaController.content.@each.didLoad')

  selectedGeoEntitiesObserver: ( ->
    @set 'selectedGeoEntitiesIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')

  selectedTaxonConceptsObserver: ( ->
    @set 'selectedTaxonConceptsIds', @get('selectedTaxonConcepts').mapProperty('id')
  ).observes('selectedTaxonConcepts.@each')

  toParams: ( ->
    {
      data_type: 'Listings'
      filters: 
        designation: @get('designation')
        appendices: @get('selectedAppendices')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        higher_taxa_ids: @get('selectedTaxonConceptsIds')
    }
  ).property('selectedAppendices.@each', 'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each')

  downloadUrl: ( ->
    '/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')

Species.DownloadsForCitesListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'cites'
  appendices: ['I', 'II', 'III']
  needs: ['higherTaxaCitesEu']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

Species.DownloadsForEuListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'eu'
  appendices: ['A', 'B', 'C', 'D']
  needs: ['higherTaxaCitesEu']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

Species.DownloadsForCmsListingsController = Species.DownloadsForDesignationListingsController.extend
  designation: 'cms'
  appendices: ['I', 'II']
  needs: ['higherTaxaCms']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCms')
  ).property()
