Trade.SearchResultsController = Ember.ArrayController.extend Trade.QueryParams, Trade.ShipmentPagination, Trade.Flash,
  needs: ['search', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null
  batchUpdateParams: Trade.ShipmentBatchUpdate.create()

  init: ->
    transaction = @get('store').transaction()
    @set('transaction', transaction)

  # note: this maps a property on the controller to a query param
  # changing a property will change the url
  queryParams: [
    'page',
    'selectedTaxonConcepts:taxon_concepts_ids',
    'selectedReportedTaxonConcepts:reported_taxon_concepts_ids',
    'selectedAppendices:appendices',
    'selectedTimeStart:time_range_start',
    'selectedTimeEnd:time_range_end',
    'selectedTerms:terms_ids',
    'selectedUnits:units_ids',
    'selectedPurposes:purposes_ids',
    'selectedSources:sources_ids',
    'selectedReporterType:reporter_type',
    'selectedImporters:importers_ids',
    'selectedExporters:exporters_ids',
    'selectedCountriesOfOrigin:countries_of_origin_ids',
    'selectedPermits:permits_ids',
    'selectedQuantity:quantity',
    'unitBlank:unit_blank',
    'purposeBlank:purpose_blank',
    'sourceBlank:source_blank',
    'countryOfOriginBlank:country_of_origin_blank',
    'permitBlank:permit_blank'
  ]

  # need to initialize those array query params
  # otherwise they're not passed as arrays
  selectedTaxonConcepts: []
  selectedReportedTaxonConcepts: []
  selectedAppendices: []
  selectedTerms: []
  selectedUnits: []
  selectedPurposes: []
  selectedSources: []
  selectedImporters: []
  selectedExporters: []
  selectedCountriesOfOrigin: []
  selectedPermits: []

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
    @transitionToRoute('search.results', {queryParams: {page: page}})

  actions:
    newShipment: () ->
      shipment = Trade.Shipment.createRecord()
      transaction = @get('transaction')
      transaction.add(shipment)
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    # saves the new shipment (bound to currentShipment) to the db
    saveShipment: (shipment, ignoreWarnings) ->
      $.ajax({
        type: 'GET'
        url: "/trade/user_can_edit"
        data: {}
        dataType: 'json'
        success: (response) ->
          console.log(response)
        error: (error) ->
          console.log(error)
      })
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
        @send("dataChanged")
      )
      shipment.one('didUpdate', this, ->
        @set('currentShipment', null)
        $('.shipment-form-modal').modal('hide')
        @flashSuccess(message: 'Successfully updated shipment.')
      )

    cancelShipment: () ->
      @get('transaction').rollback()
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')

    cancelBatch: () ->
      @set('currentShipment', null)
      $('.batch-form-modal').modal('hide')

    # discards the new shipment (bound to currentShipment)
    deleteShipment: (shipment) ->
      if confirm("This will delete a shipment. Proceed?")
        if (!shipment.get('isSaving'))
          shipment.deleteRecord()
          shipment.get('transaction').commit()
          shipment.one('didDelete', this, ->
            @set('currentShipment', null)
            @flashSuccess(message: 'Successfully deleted shipment.')
            @send("dataChanged")
          )

    deleteBatch: ->
      @transitionToRoute('search.results', {queryParams: @get('controllers.search.searchParams')})
      .then(
        # resolve
        (() =>
          if confirm("This will delete " + @get('total') + " shipments. Are you sure?")
            $.ajax(
              url: '/trade/shipments/destroy_batch'
              type: 'POST'
              data:
                filters: @get('controllers.search.searchParams')
            )
            .done( (data) =>
              @flashSuccess(message: 'Successfully deleted ' + data.rows + ' shipments.')
              @send("dataChanged")
            )
            .fail( (xhr) =>
              @flashError(message: 'Error occurred when deleting shipments.')
              console.log "bad luck: ", xhr.responseText
            )
            .always( () =>
              @set('currentShipment', null)
              $('.batch-form-modal').modal('hide')
            )
        )
      )

    editShipment: (shipment) ->
      transaction = @get('transaction')
      transaction.add(shipment)
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    editBatch: ->
      @transitionToRoute('search.results', {queryParams: @get('controllers.search.searchParams')})
      .then(
        # resolve
        (() =>
          @get('batchUpdateParams').reset()
          @set('currentShipment', @get('batchUpdateParams'))
          $('.batch-form-modal').modal('show')
        )
      )

    updateBatch: ->
      updates = @get('batchUpdateParams').export()
      if Object.keys(updates).length == 0
        alert("No changes detected.")
        return false
      if confirm("This will update " + @get('total') + " shipments. Are you sure?")
        $.ajax(
          url: '/trade/shipments/update_batch'
          type: 'POST'
          data:
            filters: @get('controllers.search.searchParams')
            updates: updates
        )
        .done( (data) =>
          @flashSuccess(message: 'Successfully updated ' + data.rows + ' shipments.')
          @send("dataChanged")
        )
        .fail( (xhr) =>
          @flashError(message: 'Error occurred when updating shipments.')
          console.log "bad luck: ", xhr.responseText
        )
        .always( () =>
          @set('currentShipment', null)
          $('.batch-form-modal').modal('hide')
        )

    resolveReportedTaxonConcept: (reported_taxon_concept_id) ->
      $.ajax(
        url: '/trade/shipments/accepted_taxa_for_reported_taxon_concept'
        type: 'GET'
        data:
          reported_taxon_concept_id: reported_taxon_concept_id
      )
      .done( (data) =>
        first = data['shipments'].shift()
        if first
          taxon_concept_id = first.id
          Trade.TaxonConcept.find(taxon_concept_id).then( () =>
            @set('currentShipment.taxonConceptId', taxon_concept_id)
          )
        else
          # there were no accepted names found, this is likely a data error
          # so clear the accepted taxon to draw attention to it
          @set('currentShipment.taxonConceptId', null)
      )
