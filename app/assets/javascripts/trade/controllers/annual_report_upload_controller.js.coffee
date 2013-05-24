Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null
  submitShipments: ()->
    $.post 'trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
      alert(data)
      'json'
