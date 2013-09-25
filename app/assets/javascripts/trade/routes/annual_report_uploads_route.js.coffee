Trade.AnnualReportUploadsRoute = Ember.Route.extend
  model: () ->
    Trade.AnnualReportUpload.find({is_done: 0})

  setupController: (controller, model) ->
    # Call _super for default behavior
    # (setting model on annual_report_uploads controller)
    @._super(controller, model)
    @controllerFor('geoEntities').set(
      'content',
      Trade.GeoEntity.find({geo_entity_type: 'country', designation: 'cites'})
    )
