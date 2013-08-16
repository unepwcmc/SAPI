Trade.AnnualReportUploadRoute = Ember.Route.extend({
  model: function(params) {
    return Trade.AnnualReportUpload.find(params.annual_report_upload_id);
  },
  setupController: function(controller, model){
    // Call _super for default behavior (as of rc4)
    this._super(controller, model)
    this.controllerFor('visibleSandboxShipments').set('content', model.get('sandboxShipments'));
  }
});
