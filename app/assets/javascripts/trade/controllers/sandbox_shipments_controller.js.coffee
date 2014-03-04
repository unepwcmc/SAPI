Trade.SandboxShipmentsController = Ember.ArrayController.extend Trade.ShipmentPagination, Trade.Flash,
  needs: ['annualReportUpload', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  updatesVisible: false
  currentShipment: null
  sandboxShipmentsSaving: false

  columns: [
    'appendix', 'taxon_name', 'accepted_taxon_name',
    'term_code', 'quantity',  'unit_code',
    'trading_partner', 'country_of_origin',
    'import_permit', 'export_permit', 'origin_permit',
    'purpose_code', 'source_code', 'year'
  ]

  allAppendices: [
    Ember.Object.create({id: 'I', name: 'I'}),
    Ember.Object.create({id: 'II', name: 'II'}),
    Ember.Object.create({id: 'III', name: 'III'}),
    Ember.Object.create({id: 'N', name: 'N'})
  ]

  sandboxShipmentsSaving: ( ->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@get('page')) + 1
    else
      parseInt(@get('page')) - 1
    @openShipmentsPage {page: page}

  openShipmentsPage: (params) ->
    sandbox_shipments_ids = @get("controllers.annualReportUpload.currentError.sandboxShipments").mapBy("id")
    queryParams = $.extend({}, sandbox_shipments_ids, params)
    @transitionToRoute('sandbox_shipments', 'sandbox_shipments_ids': queryParams)

  clearModifiedFlags: ->
    @beginPropertyChanges()
    Trade.SandboxShipment.all().forEach (shipment) ->
      shipment.set('_modified', false)
    @endPropertyChanges()

  transitionToParentController: ->
    annualReportUpload = @get('controllers.annualReportUpload')
    annualReportUpload.set('errorMessage', "")
    annualReportUploadId = annualReportUpload.get('id')
    @transitionToRoute('annual_report_upload', annualReportUploadId)

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    Trade.SandboxShipment.all().filterBy('_modified', true).length
  ).property('content.@each._modified', 'currentShipment')

  actions:

    toggleUpdatesVisible: ->
      @toggleProperty 'updatesVisible'
      # not returning false here would cause the action to bubble 
      # to the parent controller up the nested routing!
      false

    # Batch edits on the selected error
    updateSelection: () ->
      if confirm("This will update all shipments with this error. Proceed?")
        valuesToUpdate = {}
        annualReportUploadId = @get('controllers.annualReportUpload.id')
        @get('columns').forEach (columnName) =>
          el = $('.sandbox-form').find("select[name=#{columnName}],input[type=text][name=#{columnName}],input[type=hidden][name=#{columnName}]")
          blank = $('.sandbox-form')
            .find("input[type=checkbox][name=#{columnName}]:checked")
          valuesToUpdate[columnName] = el.val() if el && el.val()
          valuesToUpdate[columnName] = null if blank.length > 0
        $.ajax(
          url: "trade/annual_report_uploads/#{annualReportUploadId}/sandbox_shipments/update_batch"
          type: "POST"
          data: {
            sandbox_shipments_ids: @get("controllers.annualReportUpload.currentError.sandboxShipments").mapBy("id"),
            updates: valuesToUpdate
          }
        ).success( (data, textStatus, jqXHR) =>
          @flashSuccess(message: 'Successfully updated shipments.', persists: true)
          @get("controllers.annualReportUpload").set("currentError", null)
        ).error( (jqXHR, textStatus, errorThrown) =>
          @flashError(message: errorThrown, persists: true)
        ).complete( (jqXHR, textStatus) =>
          @transitionToParentController()
        )

    deleteSelection: () ->
      if confirm("This will delete all shipments with this error. Proceed?")
        annualReportUploadId = @get('controllers.annualReportUpload.id')
        $.ajax(
          url: "trade/annual_report_uploads/#{annualReportUploadId}/sandbox_shipments/destroy_batch"
          type: "POST"
          data: {
            sandbox_shipments_ids: @get("controllers.annualReportUpload.currentError.sandboxShipments").mapBy("id")
          }
        ).success( (data, textStatus, jqXHR) =>
          @flashSuccess(message: 'Successfully destroyed shipments.', persists: true)
          @get("controllers.annualReportUpload").set("currentError", null)
        ).error( (jqXHR, textStatus, errorThrown) =>
          @flashError(message: errorThrown, persists: true)
        ).complete( (jqXHR, textStatus) =>
          @transitionToParentController()
        )

    cancelSelectForUpdate: () ->
      $('.sandbox-form').find('select,input[type=text]').val(null)
      $('.sandbox-form .select2').select2('val', null)

    #### Save and cancel changes made on shipments table ####

    saveChanges: () ->
      Trade.SandboxShipment.filter((shipment) ->
        shipment.get('_destroyed') == true
        ).forEach (shipment) ->
        shipment.deleteRecord()
      @get('store').commit()
      @clearModifiedFlags()
      @transitionToParentController()

    cancelChanges: () ->
      @get('store').get('currentTransaction').rollback()
      @clearModifiedFlags()

    #### Single shipment related ####

    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    updateShipment: (shipment) ->
      shipment.setProperties({'_modified': true})
      @set('currentShipment', null)
      @get("controllers.annualReportUpload").set("currentError", null)
      $('.shipment-form-modal').modal('hide')

    deleteShipment: (shipment) ->
      shipment.setProperties({'_destroyed': true, '_modified': true})

    cancelShipmentEdit: (shipment) ->
      shipment.setProperties(shipment.get('data'))
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')
