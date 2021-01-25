Trade.SandboxShipmentsController = Ember.ArrayController.extend Trade.ShipmentPagination, Trade.Flash, Trade.AuthoriseUser, Trade.CustomTransition,
  needs: ['annualReportUpload', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  updatesVisible: false
  currentShipment: null
  sandboxShipmentsSaving: false
  queryParams: ['page', 'validationErrorId:validation_error_id']

  columns: [
    'appendix', 'taxon_name', 'accepted_taxon_name',
    'term_code', 'quantity', 'unit_code',
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
    @set('page', page)

  clearModifiedFlags: ->
    @beginPropertyChanges()
    Trade.SandboxShipment.all().forEach (shipment) ->
      shipment.set('_modified', false)
    @endPropertyChanges()

  transitionToParentController: ->
    model = @get('controllers.annualReportUpload.content')
    model.reload()
    @customTransitionToRoute(
      'annual_report_upload',
      model,
      false
    )
    @set('controllers.annualReportUpload.currentError', null)
    @set('controllers.annualReportUpload.allErrorsCollapsed', null)
    $('.validation-errors-loading').show()

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    Trade.SandboxShipment.all().filterBy('_modified', true).length
  ).property('content.@each._modified', 'currentShipment')

  actions:
    closeError: ->
      @get('store').get('defaultTransaction').rollback()
      @clearModifiedFlags()
      @transitionToParentController()

    toggleUpdatesVisible: ->
      @toggleProperty 'updatesVisible'
      # not returning false here would cause the action to bubble
      # to the parent controller up the nested routing!
      false

    # Batch edits on the selected error
    updateSelection: () ->
      @userCanEdit( =>
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
              validation_error_id: @get("controllers.annualReportUpload.currentError.id"),
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
      )

    deleteSelection: () ->
      @userCanEdit( =>
        if confirm("This will delete all shipments with this error. Proceed?")
          annualReportUploadId = @get('controllers.annualReportUpload.id')
          $.ajax(
            url: "trade/annual_report_uploads/#{annualReportUploadId}/sandbox_shipments/destroy_batch"
            type: "POST"
            data: {
              validation_error_id: @get("controllers.annualReportUpload.currentError.id")
            }
          ).success( (data, textStatus, jqXHR) =>
            @flashSuccess(message: 'Successfully destroyed shipments.', persists: true)
            @get("controllers.annualReportUpload").set("currentError", null)
          ).error( (jqXHR, textStatus, errorThrown) =>
            @flashError(message: errorThrown, persists: true)
          ).complete( (jqXHR, textStatus) =>
            @transitionToParentController()
          )
      )

    cancelSelectForUpdate: () ->
      $('.sandbox-form').find('select,input[type=text]').val(null)
      $('.sandbox-form .select2').select2('val', null)

    #### Save and cancel changes made on shipments table ####

    saveChanges: () ->
      @userCanEdit( =>
        Trade.SandboxShipment.filter((shipment) ->
          shipment.get('_destroyed') == true
          ).forEach (shipment) ->
          shipment.deleteRecord()
        @get('store').commit() #FIXME: IE doesn't call buildURL in rest adapter
        @clearModifiedFlags()
        @transitionToParentController()
        location.reload()
      )

    cancelChanges: () ->
      @get('store').get('defaultTransaction').rollback()
      @clearModifiedFlags()

    #### Single shipment related ####

    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    updateShipment: (shipment) ->
      shipment.setProperties({'_modified': true})
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')

    deleteShipment: (shipment) ->
      shipment.setProperties({'_destroyed': true, '_modified': true})

    cancelShipmentEdit: (shipment) ->
      shipment.setProperties(shipment.get('data'))
      shipment.set('_modified', false)
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')
