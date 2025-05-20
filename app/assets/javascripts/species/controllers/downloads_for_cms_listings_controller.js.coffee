Species.DownloadsForCmsListingsController = Ember.Controller.extend Species.EventDownloader,
  designation: 'cms'
  documentType: 'CmsListings'

  appendices: ['I', 'II']
  needs: ['geoEntities', 'higherTaxaCms', 'downloads']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCms')
  ).property()

  geoEntityQuery: null
  taxonConceptQuery: null
  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []

  toParams: ( ->
    {
      data_type: 'Listings'
      filters:
        designation: @get('designation')
        appendices: @get('selectedAppendices')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        taxon_concepts_ids: @get('selectedTaxonConceptsIds')
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property('selectedAppendices.@each', 'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each',
  'controllers.downloads.csvSeparator')
