Trade.ShipmentsController = Ember.ArrayController.extend Trade.QueryParams,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null
  csvSeparator: "comma_separated"

  init: ->
    transaction = @get('store').transaction()
    @set('transaction', transaction)

  columns: [
    'id', 'year', 'appendix', 'taxonConcept.fullName',
    'reportedTaxonConcept.fullName',
    'term.code', 'quantity',  'unit.code',
    'importer.isoCode2', 'exporter.isoCode2', 'countryOfOrigin.isoCode2',
    'purpose.code', 'source.code', 'reporterType',
    'importPermitNumber', 'exportPermitNumber', 'originPermitNumber'
  ]

  codeMappings: {
    isoCode2: "name"
    code: "name"
  }

  shipmentsSaving: ( ->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  total: ( ->
    @get('content.meta.total')
  ).property('content.isLoaded')

  perPage: ( ->
    parseInt(@get('content.meta.per_page')) || 100
  ).property("content.isLoaded")

  page: ( ->
    parseInt(@get('content.meta.page')) || 1
  ).property("content.isLoaded")

  pages: ( ->
    if @get('total')
      return Math.ceil( @get('total') / @get('perPage'))
    else
      return 1
  ).property('total', 'perPage')

  showPrevPage: ( ->
    page = @get('page')
    if page > 1 then return yes else return no
  ).property('page')

  showNextPage: ( ->
    page = @get('page')
    if page < @get('pages') then return yes else return no
  ).property('page')

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@get('page')) + 1
    else
      parseInt(@get('page')) - 1
    @openShipmentsPage {page: page}

  openShipmentsPage: (params) ->
    @transitionToRoute('shipments', queryParams: params)

  parseSelectedParams: (params) ->
    # TODO: better ideas?
    if params?.mapBy and params.mapBy('id')[0]
      return params.mapBy('id')
    if params?.mapBy
      return params
    if params?.get and params.get('id')
      return params.get('id')
    if params || typeof(params) == "boolean"
      return params
    return null

  defaultTimeStart: ( ->
    new Date().getFullYear() - 5
  ).property()
  defaultTimeEnd: ( ->
    new Date().getFullYear()
  ).property()
  years: ( ->
    [1975..new Date().getFullYear()].reverse()
  ).property()
  selectedTimeStart: ( ->
    @get('defaultTimeStart')
  ).property()
  selectedTimeEnd: ( ->
    @get('defaultTimeEnd')
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
      ranks: ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS', 'SPECIES']
      autocomplete: true
    )
  ).property('taxonConceptQuery')
  autoCompleteTaxonConceptsByRank: ( ->
    return [] unless @get('autoCompleteTaxonConcepts.meta.rank_headers')
    @get('autoCompleteTaxonConcepts.meta.rank_headers').map (rh) ->
      rank_name:rh.rank_name
      taxon_concepts: rh.taxon_concept_ids.map (tc_id) ->
        Trade.AutoCompleteTaxonConcept.find(tc_id)
  ).property('autoCompleteTaxonConcepts.meta.rank_headers')
  selectedTaxonConcepts: []
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
    @get('selectedQueryParamNames').forEach (property) =>
      value = @parseSelectedParams(@get(property.name))
      params[property.name] = value
    params
  ).property(
    'selectedTaxonConcepts.@each', 'selectedAppendices.@each',
    'selectedTimeStart', 'selectedTimeEnd', 'selectedQuantity',
    'selectedUnits.@each', 'unitBlank.@each', 'selectedTerms.@each',
    'selectedSources.@each', 'sourceBlank',
    'selectedPurposes.@each', 'purposeBlank',
    'selectedImporters.@each', 'selectedExporters.@each',
    'selectedCountriesOfOrigin.@each', 'countryOfOriginBlank',
    'selectedPermits.@each'
  )

  # sth amiss with array query params, which is why we pass a different
  # params object for transitioning than we do when parametrising the
  # download url below.
  # TODO would be good to isolate the issue with array query params
  searchParamsForTransition: ( ->
    params = {}
    for name, value of @get('searchParams')
      params[@get('queryParamsProperties')[name].param] = value
    params['page'] = @get('page')
    params['internal'] = true #TODO remove this once authentication in place
    params
  ).property('searchParams.@each', 'queryParamsProperties')

  searchParamsForUrl: ( ->
    params = {}
    for name, value of @get('searchParams')
      params[@get('queryParamsProperties')[name].urlParam] = value
    params['page'] = @get('page')
    params['internal'] = true #TODO remove this once authentication in place
    params
  ).property('searchParams.@each', 'queryParamsProperties')

  rawDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'raw'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  comptabDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'comptab'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  grossExportsDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'gross_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  grossImportsDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'gross_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  netExportsDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'net_exports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  netImportsDownloadUrl: (->
    params = @get('searchParamsForUrl')
    params['report_type'] = 'net_imports'
    params['csv_separator'] = @get('csvSeparator')
    '/trade/exports/download?' + $.param({filters: params})
  ).property('searchParamsForUrl', 'csvSeparator')

  resetFilters: ->
    @beginPropertyChanges()
    @get('selectedQueryParamNames').forEach (property) =>
      if property.type == 'array'
        @set(property.name, [])
      else if property.type == 'boolean'
        @set(property.name, false)
      else
        @set(property.name, null)
    @set('permitQuery', null)
    @set('taxonConceptQuery', null)
    @set('exporterQuery', null)
    @set('importerQuery', null)
    @set('countryOfOriginQuery', null)
    @set('termQuery', null)
    @set('unitQuery', null)
    @set('selectedTimeStart', @get('defaultTimeStart'))
    @set('selectedTimeEnd', @get('defaultTimeEnd'))
    @endPropertyChanges()
    @openShipmentsPage @get('searchParamsForTransition')

  flashMessage: (msg) ->
    $('#flash').html('
      <div class="alert alert-success fade in">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <span>' + msg + '</span>
      </div>'
    )

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
        @flashMessage('Successfully created shipment.')
        @resetFilters()
      )
      shipment.one('didUpdate', this, ->
        @set('currentShipment', null)
        $('.shipment-form-modal').modal('hide')
        @flashMessage('Successfully updated shipment.')
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
            @flashMessage('Successfully deleted shipment.')
            @resetFilters()
          )

    deleteFiltered: ->
      if confirm("This will delete all filtered shipments. Are you sure?")
        $.post '/trade/shipments/destroy_batch', @get('searchParamsForTransition'), (data) ->
           'json'
        .success( =>
          @set('currentShipment', null)
          @flashMessage('Successfully deleted filtered shipments.')
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
      @openShipmentsPage @get('searchParamsForTransition')

    resetFilters: ->
      @resetFilters()
