Trade.AnnualReportUploadRoute = Trade.BeforeRoute.extend
  model: (params) ->
    @controllerFor('geoEntities').load()
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('currentError', null)
    controller.set('allErrorsCollapsed', null)
