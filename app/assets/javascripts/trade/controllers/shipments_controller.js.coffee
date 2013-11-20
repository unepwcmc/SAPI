Trade.ShipmentsController = Ember.ArrayController.extend Trade.QueryParams,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null
  errors: null

  shipmentsSaving: ( ->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isDirty', true).length
  ).property('content.@each.isDirty')

  tableController: Ember.computed ->
    controller = Ember.get('Trade.ShipmentsTable.TableController').create()
    controller.set('shipmentsController', @)
    controller
  .property('content')

  pages: ( ->
    total = @get('content.meta.total')
    if total
      return Math.ceil( total / @get('content.meta.per_page'))
    else
      return 1
  ).property('content.meta.total')

  page: ( ->
    @get('content.meta.page') || 1
  ).property('content.meta.page')

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

  years: ( ->
    [1975..new Date().getFullYear()].reverse()
  ).property()
  selectedTimeStart: ( ->
    new Date().getFullYear()
  ).property()
  selectedTimeEnd: ( ->
    new Date().getFullYear()
  ).property()

  allAppendices: [
    {id: 'I', name: 'Appendix I'},
    {id: 'II', name: 'Appendix II'},
    {id: 'III', name: 'Appendix III'}
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
  selectedImporters: []
  selectedExporters: []
  selectedCountriesOfOrigin: []
  selectedQuantity: null

  actions:
    # TODO this might need to be dropped
    # because it will be easier to handle validations
    # if shipments are saved one by one
    saveChanges: () ->
      # process deletes
      @get('content').filterBy('_destroyed', true).forEach (shipment) ->
        shipment.deleteRecord()
      # process updates
      @get('store').commit()
      @openShipmentsPage( {page: @get('page')} )

    # TODO this might need to be dropped
    # because it will be easier to handle validations
    # if shipments are saved one by one
    cancelChanges: () ->
      @get('content').forEach (shipment) ->
        if (!shipment.get('isSaving'))
          shipment.get('transaction').rollback()

    # creates a local new shipment (bound to currentShipment)
    newShipment: () ->
      @set('currentShipment', Trade.Shipment.createRecord())
      $('.modal').modal('show')

    # saves the new shipment (bound to currentShipment) to the db
    saveShipment: () ->
      shipment = @get('currentShipment')
      # Before trying to save a shipment 
      # we need to reset the model to a valid state.
      unless shipment.get('isValid')
        shipment.send("becameValid")
      unless shipment.get('isSaving')
        shipment.get('transaction').commit()
      shipment.one('didCreate', this, ->
        @set('errors', '')
        @set('currentShipment', null)
        @set('shipment', null) #TODO: is this needed?
        $('.modal').modal('hide')
      )
      shipment.one('becameInvalid', this, ->
        @set 'errors', @get('currentShipment.errors')
      )
  
    # discards the new shipment (bound to currentShipment)
    cancelNewShipment: () ->
      shipment = @get('currentShipment')
      if (!shipment.get('isSaving'))
        @get('currentShipment').deleteRecord()
        @set('currentShipment', null)
        @set 'errors', null
        $('.modal').modal('hide')

    search: ->
      params = {}
      @selectedQueryParamNames.forEach (property) =>
        selectedParams = @get(property.name)
        params[property.param] = @parseSelectedParams(selectedParams)
      @openShipmentsPage params

    resetFilters: ->
      @selectedQueryParamNames.forEach (property) =>
        if /.+$/.test property.param
          @set(property.name, [])
        else
          @set(property.name, null)
