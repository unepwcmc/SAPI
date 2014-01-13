Trade.AnnualReportUploadRoute = Ember.Route.extend
  model: (params) ->
    @controllerFor('geoEntities').load()
    @controllerFor('sources').set('content', Trade.Source.find())
    @controllerFor('terms').set('content', Trade.Term.find())
    @controllerFor('units').set('content', Trade.Unit.find())
    @controllerFor('purposes').set('content', Trade.Purpose.find())
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)

  afterModel: (aru, transition) ->
    if (aru.get('sandboxShipments.length') == 0)
      aru.reload()
