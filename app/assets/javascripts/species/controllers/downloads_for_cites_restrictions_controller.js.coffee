Species.DownloadsForCitesRestrictionsController = Ember.Controller.extend
  designation: 'cites'

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
  documentType: 'CitesSuspensions'
  documentTypeIsCitesSuspensions: ( ->
    @get('documentType') == 'CitesSuspensions'
  ).property('documentType')

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
    {
      data_type: @get('documentType')
      filters: 
        designation: @get('designation')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        taxon_concepts_ids: @get('selectedTaxonConceptsIds')
        set: @get('timeScope')
        years: @get('selectedYears')
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property(
    'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each', 
    'timeScope', 'selectedYears.@each', 'documentType', 'controllers.downloads.csvSeparator'
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
            eventCategory: 'Downloads: ' + @get('documentType'),
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
