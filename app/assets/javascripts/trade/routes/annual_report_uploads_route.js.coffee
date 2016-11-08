Trade.AnnualReportUploadsRoute = Trade.BeforeRoute.extend
  model: () ->
    @controllerFor('geoEntities').load()
    Trade.AnnualReportUpload.find({submitted_at: null})
