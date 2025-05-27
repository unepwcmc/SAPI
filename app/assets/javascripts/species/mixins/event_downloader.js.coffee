Species.EventDownloader = Ember.Mixin.create
  documentType: 'UnknownDocumentType'
  needs: ['geoEntities', 'downloads']

  higherTaxaController: ( ->
    throw new Error('Unimplemented')
  ).property()

  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []
  selectedYears: []

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
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property(
    'documentType', 'controllers.downloads.csvSeparator'
  )

  downloadUrl: ( ->
    '/species/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')

  analyticsEventProperties: ( ->
    {
      download_type: @get('documentType'),
      format: 'CSV',
      separator: @get('controllers.downloads.csvSeparator')
    }
  ).property('documentType', 'controllers.downloads.csvSeparator')

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

          analytics.gtag(
            'event', 'download_started', @get('analyticsEventProperties')
          )

          window.location = @get('downloadUrl')

          return
        else
          analytics.gtag(
            'event', 'download_empty', @get('analyticsEventProperties')
          )

          @set('downloadMessage', 'No results')
      ).fail((jqXHR) =>
        @set('downloadInProgress', false)

        errorStatusText = jqXHR.statusText || 'Unknown error'

        @set('downloadMessage', 'Download Failed (' + errorStatusText + ')')

        analytics.gtag(
          'event', 'download_failed', @get('analyticsEventProperties')
        )
      )

    deleteTaxonConceptSelection: (context) ->
      @set('selectedTaxonConcepts', [])

    deleteGeoEntitySelection: (context) ->
      @get('selectedGeoEntities').removeObject(context)

    deleteYearSelection: (context) ->
      @get('selectedYears').removeObject(Number(context))
