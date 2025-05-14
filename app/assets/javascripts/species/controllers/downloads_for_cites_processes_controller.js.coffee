Species.DownloadsForCitesProcessesController = Ember.Controller.extend Species.EventDownloader,
  designation: 'cites'
  documentType: 'CitesSuspensions'

  needs: ['geoEntities','higherTaxaCitesEu', 'downloads']

  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

  geoEntityQuery: null
  taxonConceptQuery: null
  selectedGeoEntities: []
  selectedTaxonConcepts: []
  timeScope: 'current'
  timeScopeIsCurrent: ( ->
    @get('timeScope') == 'current'
  ).property('timeScope')
  years: [1975..new Date().getFullYear()]
  selectedYears: []
  processType: 'Both'
  documentTypeIsCitesSuspensions: ( ->
    @get('documentType') == 'CitesSuspensions'
  ).property('documentType')

  toParams: ( ->
    {
      data_type: 'Processes'
      filters:
        process_type: @get('processType')
        designation: @get('designation')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        taxon_concepts_ids: @get('selectedTaxonConceptsIds')
        set: @get('timeScope')
        years: @get('selectedYears')
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property(
    'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each',
    'timeScope', 'selectedYears.@each', 'processType', 'controllers.downloads.csvSeparator'
  )
