Trade.AnnualReportUploadRoute = Ember.Route.extend
  model: (params) ->
    Trade.AnnualReportUpload.find(params.annual_report_upload_id)

  setupController: (controller, model) ->
    # Call _super for default behavior
    # (setting model on annual_report_uploads controller)
    @._super(controller, model)
    @controllerFor('geoEntities').set(
      'content',
      Trade.GeoEntity.find({geo_entity_type: 'country', designation: 'cites'})
    )