Trade.AnnualReportUploadsRoute = Ember.Route.extend({
  model: function() {
    return Trade.AnnualReportUpload.find();
  }
});
