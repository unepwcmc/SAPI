Species.DownloadsForCitesListingsController = Ember.Controller.extend Species.EventDownloader,
  designation: 'cites'
  documentType: 'CitesListings'

  appendices: ['I', 'II', 'III']
  needs: ['geoEntities', 'higherTaxaCitesEu', 'downloads']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()
  selectedAppendices: []
  geoEntityQuery: null
  taxonConceptQuery: null
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
