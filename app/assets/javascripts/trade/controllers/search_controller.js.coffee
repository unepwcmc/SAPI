Trade.SearchController = Ember.Controller.extend Trade.QueryParams, Trade.Flash, Trade.CustomTransition,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null
  csvSeparator: 'comma'
  batchUpdateParams: Trade.ShipmentBatchUpdate.create()

  init: ->
    @set('selectedTimeStart', @get('defaultTimeStart'))
    @set('selectedTimeEnd', @get('defaultTimeEnd'))

  defaultTimeStart: ( ->
    new Date().getFullYear() - 5
  ).property()
  defaultTimeEnd: ( ->
    new Date().getFullYear()
  ).property()
  years: ( ->
    [1975..new Date().getFullYear()].reverse()
  ).property()

  allAppendices: [
    Ember.Object.create({id: 'I', name: 'Appendix I'}),
    Ember.Object.create({id: 'II', name: 'Appendix II'}),
    Ember.Object.create({id: 'III', name: 'Appendix III'})
    Ember.Object.create({id: 'N', name: 'Appendix N'})
  ]
  allReporterTypeValues: ['E', 'I']

  permitQuery: null
  autoCompletePermits: ( ->
    permitQuery = @get('permitQuery')
    if !permitQuery || permitQuery.length < 3
      return;
    Trade.Permit.find(
      permit_query: @get('permitQuery')
    )
  ).property('permitQuery')
  selectedPermits: []

  taxonConceptQuery: null
  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if !taxonConceptQuery || taxonConceptQuery.length < 3
      return [];
    Trade.AutoCompleteTaxonConcept.find(
      taxonomy: 'CITES'
      taxon_concept_query: taxonConceptQuery
      visibility: 'trade_internal'
    )
  ).property('taxonConceptQuery')
  autoCompleteTaxonConceptsByRank: ( ->
    return [] unless @get('autoCompleteTaxonConcepts.meta.rank_headers')
    @get('autoCompleteTaxonConcepts.meta.rank_headers').map (rh) ->
      rank_name:rh.rank_name
      taxon_concepts: rh.taxon_concept_ids.map (tc_id) ->
        Trade.AutoCompleteTaxonConcept.find(tc_id)
  ).property('autoCompleteTaxonConcepts.meta.rank_headers')
  reportedTaxonConceptQuery: null
  autoCompleteReportedTaxonConcepts: ( ->
    taxonConceptQuery = @get('reportedTaxonConceptQuery')
    if !taxonConceptQuery || taxonConceptQuery.length < 3
      return [];
    Trade.AutoCompleteTaxonConcept.find(
      taxonomy: 'CITES'
      taxon_concept_query: taxonConceptQuery
      visibility: 'trade_internal'
      include_synonyms: true
    )
  ).property('reportedTaxonConceptQuery')
  autoCompleteReportedTaxonConceptsByRank: ( ->
    return [] unless @get('autoCompleteReportedTaxonConcepts.meta.rank_headers')
    @get('autoCompleteReportedTaxonConcepts.meta.rank_headers').map (rh) ->
      rank_name:rh.rank_name
      taxon_concepts: rh.taxon_concept_ids.map (tc_id) ->
        Trade.AutoCompleteTaxonConcept.find(tc_id)
  ).property('autoCompleteReportedTaxonConcepts.meta.rank_headers')
  selectedTaxonConcepts: []
  selectedReportedTaxonConcepts: []
  selectedAppendices: []
  selectedTerms: []
  selectedUnits: []
  selectedPurposes: []
  selectedSources: []
  importerQuery: null
  autoCompleteImporters: ( ->
    @autoCompleteObjects('controllers.geoEntities', 'name', @get('importerQuery'))
  ).property('importerQuery')
  selectedImporters: []
  exporterQuery: null
  autoCompleteExporters: ( ->
    @autoCompleteObjects('controllers.geoEntities', 'name', @get('exporterQuery'))
  ).property('exporterQuery')
  selectedExporters: []
  countryOfOriginQuery: null
  autoCompleteCountriesOfOrigin: ( ->
    @autoCompleteObjects('controllers.geoEntities', 'name', @get('countryOfOriginQuery'))
  ).property('countryOfOriginQuery')
  selectedCountriesOfOrigin: []
  selectedQuantity: null
  unitBlank: false
  purposeBlank: false
  sourceBlank: false
  countryOfOriginBlank: false
  permitBlank: false
  termQuery: null
  autoCompleteTerms: ( ->
    @autoCompleteObjects('controllers.terms', 'code', @get('termQuery'))
  ).property('termQuery')
  unitQuery: null
  autoCompleteUnits: ( ->
    @autoCompleteObjects('controllers.units', 'code', @get('unitQuery'))
  ).property('unitQuery')

  autoCompleteObjects: (collectionName, columnName, query) ->
    return @get(collectionName) unless query
    if collectionName != 'controllers.geoEntities'
      query = "^" + query
    else
      query = "(^|\\(| )" + query
    re = new RegExp(query, "i")
    @get(collectionName).filter (element) ->
      re.test(element.get(columnName))

  searchParams: ( ->
    params = {}
    @get('propertyMapping').forEach( (p) =>
      if p.type == 'array'
        params[p.urlParam] = @get(p.name).mapBy('id')
      else
        params[p.urlParam] = @get(p.name)
    )
    params
  ).property(
    'selectedTaxonConcepts.@each',
    'selectedReportedTaxonConcepts.@each',
    'selectedAppendices.@each',
    'selectedTimeStart', 'selectedTimeEnd', 'selectedQuantity',
    'selectedUnits.@each', 'unitBlank.@each', 'selectedTerms.@each',
    'selectedSources.@each', 'sourceBlank',
    'selectedPurposes.@each', 'purposeBlank',
    'selectedReporterType',
    'selectedImporters.@each', 'selectedExporters.@each',
    'selectedCountriesOfOrigin.@each', 'countryOfOriginBlank',
    'selectedPermits.@each', 'permitBlank'
  )

  selectionSummary: ( ->
    result = []
    @get('propertyMapping').forEach( (p) =>
      if p.type == 'array'
        if @get(p.name).length > 0
          result.push p.displayTitle + ': ' + @get(p.name).mapBy(p.displayProperty)
      else if p.type == 'boolean'
        if @get(p.name) == true
          result.push p.displayTitle + ': ' + @get(p.name)
      else
        if @get(p.name)
          result.push p.displayTitle + ': ' + @get(p.name)
    )
    result.join(', ')
  ).property('searchParams')

  rawDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'raw'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  comptabDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'comptab'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  grossExportsDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'gross_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  grossImportsDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'gross_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  netExportsDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'net_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  netImportsDownloadUrl: (->
    params = $.extend({}, @get('searchParams'))
    params['report_type'] = 'net_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  searchParamsFromQueryParams: (params) ->
    @get('propertyMapping').forEach( (p) =>
      selection = if p.type == 'array' && p.collectionPath
        @get(p.collectionPath).filter( (item) ->
          params[p.urlParam].findBy(item.get('id')) != undefined
        )
      else
        params[p.urlParam]
      @set(p.name, selection)
    )

  resetFilters: ->
    @beginPropertyChanges()
    @get('propertyMapping').forEach (property) =>
      if property.type == 'array'
        @set(property.name, [])
      else if property.type == 'boolean'
        @set(property.name, false)
      else
        @set(property.name, null)
    [
      'taxonConcept', 'reportedTaxonConcept', 'importer', 'exporter',
      'countryOfOrigin', 'term', 'unit', 'permit'
    ].forEach (autoCompleteField) =>
      @set(autoCompleteField + 'Query', null)
    @set('selectedTimeStart', @get('defaultTimeStart'))
    @set('selectedTimeEnd', @get('defaultTimeEnd'))
    # this is the lamest search form reset code ever
    # the issue being that Ember.Select seems to be broken and does not update
    $('select[name=reporter_type]').val(null)
    $('select[name=time_start]').val(@get('selectedTimeStart'))
    $('select[name=time_end]').val(@get('selectedTimeEnd'))
    @endPropertyChanges()

  actions:
    search: ->
      @flashClear()
      @customTransitionToRoute('search.results', {queryParams: @get('searchParams')})

    resetFilters: ->
      @flashClear()
      @resetFilters()
      @customTransitionToRoute('search.results', {queryParams: @get('searchParams')})
