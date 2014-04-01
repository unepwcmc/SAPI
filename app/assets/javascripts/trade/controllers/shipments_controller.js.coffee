Trade.ShipmentsController = Ember.ArrayController.extend Trade.QueryParams, Trade.ShipmentPagination, Trade.Flash,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null
  csvSeparator: "comma_separated"

  init: ->
    transaction = @get('store').transaction()
    @set('transaction', transaction)
    @set('selectedTimeStart', @get('defaultTimeStart'))
    @set('selectedTimeEnd', @get('defaultTimeEnd'))

  columns: [
    'id', 'year', 'appendix', 'taxonConcept.fullName',
    'reportedTaxonConcept.fullName',
    'term.code', 'quantity',  'unit.code',
    'importer.isoCode2', 'exporter.isoCode2', 'countryOfOrigin.isoCode2',
    'purpose.code', 'source.code', 'reporterType',
    'importPermitNumber', 'exportPermitNumber', 'originPermitNumber',
    'legacyShipmentNumber'
  ]

  codeMappings: {
    isoCode2: "name"
    code: "name"
  }

  shipmentsSaving: ( ->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@get('page')) + 1
    else
      parseInt(@get('page')) - 1
    @set('page', page)
    @updateQueryParams()

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
    re = new RegExp("^" + query, "i")
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

  rawDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'raw'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  comptabDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'comptab'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  grossExportsDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'gross_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  grossImportsDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'gross_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  netExportsDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'net_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  netImportsDownloadUrl: (->
    params = @get('searchParams')
    params['report_type'] = 'net_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParams', 'csvSeparator')

  updateQueryParams: ->
    @beginPropertyChanges()
    @get('propertyMapping').forEach( (p) =>
      if p.type == 'array'
        @set(p.param, @get(p.name).mapBy('id'))
      else
        @set(p.param, @get(p.name))
    )
    @endPropertyChanges()

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
    @endPropertyChanges()
    @updateQueryParams()

  actions:

    # creates a local new shipment (bound to currentShipment)

    newShipment: () ->
      @set('currentShipment', Trade.Shipment.createRecord())
      $('.shipment-form-modal').modal('show')

    # saves the new shipment (bound to currentShipment) to the db
    saveShipment: (shipment, ignoreWarnings) ->
      shipment.set('ignoreWarnings', ignoreWarnings)
      # Before trying to save a shipment
      # we need to reset the model to a valid state.
      unless shipment.get('isValid')
        shipment.send("becameValid")
      unless shipment.get('isSaving')
        transaction = @get('transaction')
        transaction.add(shipment)
        transaction.commit()
      # this is here so that after another validation
      # the user gets the secondary validation warning
      shipment.set('propertyChanged', false)
      shipment.one('didCreate', this, ->
        @set('currentShipment', null)
        $('.shipment-form-modal').modal('hide')
        @flashSuccess(message: 'Successfully created shipment.')
        @resetFilters()
      )
      shipment.one('didUpdate', this, ->
        @set('currentShipment', null)
        $('.shipment-form-modal').modal('hide')
        @flashSuccess(message: 'Successfully updated shipment.')
        @resetFilters()
      )

    cancelShipment: () ->
      @get('transaction').rollback()
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')

    # discards the new shipment (bound to currentShipment)
    deleteShipment: (shipment) ->
      if confirm("This will delete a shipment. Proceed?")
        if (!shipment.get('isSaving'))
          shipment.deleteRecord()
          shipment.get('transaction').commit()
          shipment.one('didDelete', this, ->
            @set('currentShipment', null)
            @flashSuccess(message: 'Successfully deleted shipment.')
            @resetFilters()
          )

    deleteFiltered: ->
      if confirm("This will delete all filtered shipments. Are you sure?")
        $.post '/trade/shipments/destroy_batch', @get('searchParams'), (data) ->
           'json'
        .success( =>
          @set('currentShipment', null)
          @flashSuccess(message: 'Successfully deleted filtered shipments.')
          @resetFilters()
        )
        #.error( (xhr, msg, error) =>
        #  @set('sandboxShipmentsSubmitting', false)
        #  console.log "bad luck: ", xhr.responseText
        #)


    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    search: ->
      @flashClear()
      @updateQueryParams()

    resetFilters: ->
      @flashClear()
      @resetFilters()
