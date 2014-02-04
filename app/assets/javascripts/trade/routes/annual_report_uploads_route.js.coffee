Trade.AnnualReportUploadsRoute = Trade.BeforeRoute.extend
  model: () ->
    @controllerFor('geoEntities').load()
    Trade.AnnualReportUpload.find({is_done: 0})
