Species.DownloadsForEuDecisionsController = Ember.Controller.extend Species.EventDownloader,
  designation: 'eu'
  documentType: 'EuDecisions'

  needs: ['geoEntities', 'higherTaxaCitesEu', 'downloads']

  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

  geoEntityQuery: null
  taxonConceptQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedTaxonConcepts: []
  timeScope: 'current'
  timeScopeIsCurrent: ( ->
    current = @get('timeScope') == 'current'
    if current
      @set('selectedYears', [])
    current
  ).property('timeScope')
  years: [1975..new Date().getFullYear()]
  selectedYears: []
  positiveOpinions: true
  negativeOpinions: true
  noOpinions: true
  srgReferral: true
  suspensions: true
  inConsultation: true
  underTracking: true
  discussedAtSrg: false
  euDecisionFilter: 'Default'
  euDecisionFilterIsDefault: ( ->
    @get('euDecisionFilter') == 'Default'
  ).property('euDecisionFilter')

  toParams: ( ->
    # IF EU DECISION FILTER IS "IN CONSULTATION" - DON'T APPLY ALL FILTERS
    if @get('euDecisionFilter').toUpperCase() == 'SRG HISTORY'
      {
        data_type: 'EuDecisions'
        filters: {
          designation: @get('designation')
          csv_separator: @get('controllers.downloads.csvSeparator')
          eu_decision_filter: @get('euDecisionFilter')
          srg_history_types: {
            inConsultation: @get('inConsultation')
            underTracking: @get('underTracking')
            discussedAtSrg: @get('discussedAtSrg')
          }
        }
      }
    else
      {
        data_type: 'EuDecisions'
        filters: {
          ####################################################
          ########## DEFAULT EU DECISION FILTERS #############
          ####################################################
          designation: @get('designation')
          csv_separator: @get('controllers.downloads.csvSeparator')
          eu_decision_filter: @get('euDecisionFilter')
          ####################################################
          geo_entities_ids: @get('selectedGeoEntitiesIds')
          set: @get('timeScope')
          taxon_concepts_ids: @get('selectedTaxonConceptsIds')
          years: @get('selectedYears')
          decision_types: {
            negativeOpinions: @get('negativeOpinions')
            noOpinions: @get('noOpinions')
            positiveOpinions: @get('positiveOpinions')
            srgReferral: @get('srgReferral')
            suspensions: @get('suspensions')
          }
          ####################################################
          ####################################################
          ####################################################
        }
      }

  ).property(
    'controllers.downloads.csvSeparator',
    'euDecisionFilter',
    'negativeOpinions',
    'noOpinions',
    'positiveOpinions',
    'selectedGeoEntitiesIds.@each',
    'selectedTaxonConceptsIds.@each',
    'selectedYears.@each',
    'srgReferral',
    'suspensions',
    'inConsultation',
    'underTracking',
    'discussedAtSrg',
    'timeScope'
  )