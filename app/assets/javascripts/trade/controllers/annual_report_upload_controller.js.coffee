Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null
  needs: ['visibleSandboxShipments']

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

    saveShipments: () ->
        @get('store').commit()
        console.log('changes saved')
        @transitionToRoute('annual_report_upload', @)

    destroyShipment: (shipment) ->
      if (window.confirm("Are you sure you want to delete this shipment?"))
        shipment.deleteRecord()
        @get('store').commit()
        @transitionToRoute('annual_report_upload', @)
