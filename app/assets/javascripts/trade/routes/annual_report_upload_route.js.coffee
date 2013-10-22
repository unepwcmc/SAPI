Trade.AnnualReportUploadRoute = Ember.Route.extend
  model: (params) ->
    @controllerFor('geoEntities').load()
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)

  afterModel: (aru, transition) ->
    if (aru.get('sandboxShipments.length') == 0)
      aru.reload()
