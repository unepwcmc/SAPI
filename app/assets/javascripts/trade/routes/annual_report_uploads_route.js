Trade.AnnualReportUploadsRoute = Ember.Route.extend({
  model: function() {
    return Trade.AnnualReportUpload.find();
  },
  setupController: function(controller, model){
     this.controllerFor('geoEntities').set('content', Trade.GeoEntity.find());
  }
});
