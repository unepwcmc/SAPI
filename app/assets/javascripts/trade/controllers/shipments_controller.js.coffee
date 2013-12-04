Trade.ShipmentsController = Ember.ArrayController.extend Trade.QueryParams,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null

  columns: [
    'taxonConcept.fullName', 'year', 'quantity', 'appendix', 'term.code',
    'unit.code', 'importer.isoCode2', 'exporter.isoCode2', 'countryOfOrigin.isoCode2',
    'importPermitNumber', 'exportPermitNumber', 'countryOfOriginPermitNumber',
    'purpose.code', 'source.code'
  ]

  codeMappings: {
    isoCode2: "name"
    code: "nameEn"
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
    params.page = params.page or 1
    @transitionToRoute('shipments', {queryParams: params})

  parseSelectedParams: (params) ->
    # TODO: better ideas?
    if params?.mapBy and params.mapBy('id')[0]
      return params.mapBy('id')
    if params?.mapBy
      return params
    if params?.get and params.get('id')
      return params.get('id')
    if params
      return params
    return []

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

  actions:
    # creates a local new shipment (bound to currentShipment)
    newShipment: () ->
      @set('currentShipment', Trade.Shipment.createRecord())
      $('.modal').modal('show')

    # saves the new shipment (bound to currentShipment) to the db
    saveShipment: (ignoreWarnings) ->
      shipment = @get('currentShipment')
      shipment.set('ignoreWarnings', ignoreWarnings)
      # Before trying to save a shipment
      # we need to reset the model to a valid state.
      unless shipment.get('isValid')
        shipment.send("becameValid")
      unless shipment.get('isSaving')
        shipment.get('transaction').commit()
      # this is here so that after another validation
      # the user gets the secondary validation warning
      shipment.set('propertyChanged', false)
      shipment.one('didCreate', this, ->
        @set('currentShipment', null)
        $('.modal').modal('hide')
        @send('search')
      )
      shipment.one('didUpdate', this, ->
        @set('currentShipment', null)
        $('.modal').modal('hide')
        @send('search')
      )

    cancelShipment: () ->
      @set('currentShipment', null)
      $('.modal').modal('hide')

    # discards the new shipment (bound to currentShipment)
    deleteShipment: (shipment) ->
      if (!shipment.get('isSaving'))
        shipment.deleteRecord()
        shipment.get('transaction').commit()
        shipment.one('didDelete', this, ->
          @set('currentShipment', null)
          @send('search')
        )

    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.modal').modal('show')

    search: ->
      params = {}
      @selectedQueryParamNames.forEach (property) =>
        selectedParams = @get(property.name)
        params[property.param] = @parseSelectedParams(selectedParams)
        params['unit_blank'] = @get('unitBlank')
        params['purpose_blank'] = @get('purposeBlank')
        params['source_blank'] = @get('sourceBlank')
        params['country_of_origin_blank'] = @get('countryOfOriginBlank')
      @openShipmentsPage params

    resetFilters: ->
      @selectedQueryParamNames.forEach (property) =>
        if /.+$/.test property.param
          @set(property.name, [])
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
      @openShipmentsPage(false)
