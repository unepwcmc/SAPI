SAPI.AnnualReportsRoute = Ember.Route.extend({
  model: function() {
    return SAPI.AnnualReport.find();
  }
});
