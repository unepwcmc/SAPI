Trade.AnnualReportUploadRoute = Ember.Route.extend({
  model: function(params) {
    return Trade.AnnualReportUpload.find(params.annual_report_upload_id);
  }
});
