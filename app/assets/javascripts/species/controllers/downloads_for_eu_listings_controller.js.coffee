Species.DownloadsForEuListingsController = Ember.Controller.extend Species.EventDownloader,
  designation: 'eu'
  documentType: 'EuListings'

  appendices: ['A', 'B', 'C', 'D']
  needs: ['geoEntities', 'higherTaxaCitesEu', 'downloads']
  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

  selectedAppendices: []
  geoEntityQuery: null
  taxonConceptQuery: null
  selectedGeoEntities: []
  selectedTaxonConcepts: []
  includeCites: null

  toParams: ( ->
    {
      data_type: 'Listings'
      filters:
        designation: @get('designation')
        appendices: @get('selectedAppendices')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        taxon_concepts_ids: @get('selectedTaxonConceptsIds')
        include_cites: @get('includeCites')
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property(
    'selectedAppendices.@each',
    'selectedGeoEntitiesIds.@each',
    'selectedTaxonConceptsIds.@each',
    'includeCites',
    'controllers.downloads.csvSeparator'
  )
