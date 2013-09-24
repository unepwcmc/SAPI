Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null

  tableController: Ember.computed ->
    controller = Ember.get('Trade.SandboxShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content.sandboxShipments')
    controller
  .property()

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
      @transitionToRoute('annual_report_upload', @.get('content'))
