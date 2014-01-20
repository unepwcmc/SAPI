Trade.SandboxShipmentsController = Ember.ArrayController.extend
  needs: ['annualReportUpload', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  updatesVisible: false
  currentShipment: null

  sandboxShipmentsSaving: false # FIXME

  columns: [
    'appendix', 'speciesName',
    'termCode', 'quantity',  'unitCode',
    'tradingPartner', 'countryOfOrigin',
    'importPermit', 'exportPermit', 'originPermit',
    'purposeCode', 'sourceCode', 'year'
  ]

  allAppendices: [
    Ember.Object.create({id: 'I', name: 'I'}),
    Ember.Object.create({id: 'II', name: 'II'}),
    Ember.Object.create({id: 'III', name: 'III'}),
    Ember.Object.create({id: 'N', name: 'N'})
  ]

  # FIXME
  #sandboxShipmentsSaving: ( ->
  #  @get('content.isSaving')
  #).property('content.isSaving')
  sandboxShipmentsSubmitting: false

  clearModifiedFlags: ->
    @beginPropertyChanges()
    @get('content').forEach (shipment) ->
      shipment.set('_modified', false)
    @endPropertyChanges()

  actions:

    toggleUpdatesVisible: ->
      @toggleProperty 'updatesVisible'
      # not returning false here would cause the action to bubble 
      # to the parent controller up the nested routing!
      false

    saveChanges: () ->
      @get('store').commit()
      #@transitionToRoute('annual_report_upload', @get('content'))
      @clearModifiedFlags()

    updateSelection: () ->
      valuesToUpdate = {}
      annualReportUploadId = @get('controllers.annualReportUpload.id')
      @get('columns').forEach (columnName) =>
        el = $('.sandbox-form').find('input[type=text][name=' + columnName + ']')
        blank = $('.sandbox-form').find('input[type=checkbox][name=' + columnName + ']:checked')
        valuesToUpdate[columnName] = el.val() if el && el.val()
        valuesToUpdate[columnName] = null if blank.length > 0
      #TODO: better ideas? 
      $.when($.ajax({
        url: "trade/annual_report_uploads/#{annualReportUploadId}/"
        type: "PUT"
        data: valuesToUpdate
      })).then( 
        @transitionToRoute('annual_report_upload', annualReportUploadId), 
        console.log arguments
      )

    #### Single shipment related ####

    editShipment: (shipment) ->
      #this.get('controllers.annualReportUpload.id')
      #debugger
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
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')
