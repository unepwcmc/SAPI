Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null
  needs: ['visibleSandboxShipments']

  submitShipments: ()->
    $.post '/trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
      console.log(data)
      'json'
    @transitionToRoute('annual_report_uploads')

  showMatchingRecords: (context) ->
    @set('controllers.visibleSandboxShipments.content', context.get('sandboxShipments'))
