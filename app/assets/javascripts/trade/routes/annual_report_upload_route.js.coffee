Trade.AnnualReportUploadRoute = Ember.Route.extend
  model: (params) ->
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)
