Trade.AnnualReportsRoute = Ember.Route.extend({
  model: function() {
    return Trade.AnnualReport.find();
  }
});
