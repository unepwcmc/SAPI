Species.DownloadsForEuDecisionsController = Ember.Controller.extend
  designation: 'eu'

  needs: ['geoEntities', 'higherTaxaCitesEu']

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
    @get('timeScope') == 'current'
  ).property('timeScope')
  years: [1975..2013]
  selectedYears: []
  positiveOpinions: true
  negativeOpinions: true
  noOpinions: true
  suspensions: true

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
      re = new RegExp("^"+@get('geoEntityQuery'),"i")
      @get('controllers.geoEntities.regions')
        .filter (item, index, enumerable) =>
          re.test item.get('name')
    else
      @get('controllers.geoEntities.regions')
  ).property('controllers.geoEntities.regions.@each', 'geoEntityQuery')

  autoCompleteCountries: ( ->
    if @get('geoEntityQuery') && @get('geoEntityQuery').length > 0
      re = new RegExp("^"+@get('geoEntityQuery'),"i")
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
    {
      data_type: 'EuDecisions'
      filters: 
        designation: @get('designation')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        taxon_concepts_ids: @get('selectedTaxonConceptsIds')
        set: @get('timeScope')
        years: @get('selectedYears')
        decision_types:
          {
            positiveOpinions: @get('positiveOpinions')
            negativeOpinions: @get('negativeOpinions')
            noOpinions: @get('noOpinions')
            suspensions: @get('suspensions')
          }
    }
  ).property(
    'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each', 
    'timeScope', 'years.@each', 'positiveOpinions', 'negativeOpinions',
    'noOpinions', 'suspensions'
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
          window.location = @get('downloadUrl')
          return
        else
          @set('downloadMessage', 'No results')
      )
