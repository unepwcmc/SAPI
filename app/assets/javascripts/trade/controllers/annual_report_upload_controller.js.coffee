Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null

  tableController: Ember.computed ->
    controller = Ember.get('Trade.SandboxShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content.sandboxShipments')
    controller
  .property()

  unsavedChanges: (->
    @get('content.isDirty')
  ).property('content.isDirty')

  appendix: []
  appendixBlank: false

  actions:
    submitShipments: ()->
      $.post '/trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
        console.log(data)
        'json'
      @transitionToRoute('annual_report_uploads')

    showMatchingRecords: (context) ->
      @set('tableController.shipments', context.get('sandboxShipments'))

    saveChanges: () ->
      @get('store').commit()
      @transitionToRoute('annual_report_upload', @get('content'))

    cancelChanges: () ->
      if (!@get('content').get('isSaving'))
        @get('content').get('transaction').rollback() 

    resetFilters: () ->
      #TODO
      console.log('resetting filters')