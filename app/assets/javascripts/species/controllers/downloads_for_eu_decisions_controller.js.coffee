Species.DownloadsForEuDecisionsController = Ember.Controller.extend
  designation: 'eu'

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
  euDecisionFilter: 'Default'
  euDecisionFilterIsDefault: ( ->
    @get('euDecisionFilter') == 'Default'
  ).property('euDecisionFilter')

  autoCompleteTaxonConcepts: ( ->
    if @get('taxonConceptQuery') && @get('taxonConceptQuery').length > 0
      re = new RegExp("^"+@get('taxonConceptQuery'),"i")
      @get('higherTaxaController.contentByRank')
      .map((e) =>
        {
          rankName: e.rankName
          taxonConcepts: e.taxonConcepts.filter((item) =>
            re.test item.get('fullName')
          )
        }
      ).filter((e) ->
        e.taxonConcepts.length > 0
      )
    else
      @get('higherTaxaController.contentByRank')
  ).property('higherTaxaController.contentByRank.@each', 'taxonConceptQuery')

  autoCompleteRegions: ( ->
    if @get('geoEntityQuery') && @get('geoEntityQuery').length > 0
      re = new RegExp("(^|\\(| )"+@get('geoEntityQuery'),"i")
      @get('controllers.geoEntities.regions')
        .filter (item, index, enumerable) =>
          re.test item.get('name')
    else
      @get('controllers.geoEntities.regions')
  ).property('controllers.geoEntities.regions.@each', 'geoEntityQuery')

  autoCompleteCountries: ( ->
    if @get('geoEntityQuery') && @get('geoEntityQuery').length > 0
      re = new RegExp("(^|\\(| )"+@get('geoEntityQuery'),"i")
      @get('controllers.geoEntities.countries')
        .filter (item, index, enumerable) =>
          re.test item.get('name')
    else
      @get('controllers.geoEntities.countries')
  ).property('controllers.geoEntities.countries.@each', 'geoEntityQuery')

  selectedGeoEntitiesIds: ( ->
    @get('selectedGeoEntities').mapProperty('id')
  ).property('selectedGeoEntities.@each')

  selectedTaxonConceptsIds: ( ->
    @get('selectedTaxonConcepts').mapProperty('id')
  ).property('selectedTaxonConcepts.@each')

  toParams: ( ->
    # IF EU DECISION FILTER IS "IN CONSULTATION" - DON'T APPLY ALL FILTERS
    if @get('euDecisionFilter').toUpperCase() == 'IN CONSULTATION'
      {
        data_type: 'EuDecisions'
        filters: {
          designation: @get('designation')
          csv_separator: @get('controllers.downloads.csvSeparator')
          eu_decision_filter: @get('euDecisionFilter')
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
    'timeScope'
  )

  downloadUrl: ( ->
    '/species/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')

  actions:
    startDownload: () ->
      @set('downloadInProgress', true)
      @set('downloadMessage', 'Downloading...')
      $.ajax({
        type: 'GET'
        dataType: 'json'
        url: @get('downloadUrl')
      }).done((data) =>
        @set('downloadInProgress', false)
        if data.total > 0
          @set('downloadMessage', null)
          ga('send', {
            hitType: 'event',
            eventCategory: 'Downloads: EU Decisions',
            eventAction: 'Format: CSV',
            eventLabel: @get('controllers.downloads.csvSeparator')
          })
          window.location = @get('downloadUrl')
          return
        else
          @set('downloadMessage', 'No results')
      )

    deleteTaxonConceptSelection: (context) ->
      @set('selectedTaxonConcepts', [])

    deleteGeoEntitySelection: (context) ->
      @get('selectedGeoEntities').removeObject(context)

    deleteYearSelection: (context) ->
      @get('selectedYears').removeObject(Number(context))
