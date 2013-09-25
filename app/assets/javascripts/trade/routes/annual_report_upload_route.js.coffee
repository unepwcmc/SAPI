Trade.AnnualReportUploadRoute = Ember.Route.extend
  model: (params) ->
    @controllerFor('geoEntities').load()
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)
