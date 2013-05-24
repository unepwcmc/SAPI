Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null
  needs: ['visibleSandboxShipments']
  showMatchingRecords: (context) ->
    @set('controllers.visibleSandboxShipments.content', context.get('sandboxShipments'))
