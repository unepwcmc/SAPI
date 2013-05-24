Trade.AnnualReportUploadRoute = Ember.Route.extend({
  model: function(params) {
    return Trade.AnnualReportUpload.find(params.annual_report_upload_id);
  },
  setupController: function(controller, model){
    this.controllerFor('visibleSandboxShipments').set('content', model.get('sandboxShipments'));
  }
});
