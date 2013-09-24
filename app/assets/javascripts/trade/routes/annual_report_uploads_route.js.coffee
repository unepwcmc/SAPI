Trade.AnnualReportUploadsRoute = Ember.Route.extend
  model: () ->
    Trade.AnnualReportUpload.find()

  setupController: (controller, model) ->
    @.controllerFor('geoEntities').set(
      'content',
      Trade.GeoEntity.find({geo_entity_type: 'country', designation: 'cites'})
    )
