Trade.ValidationRulesRoute = Ember.Route.extend({
  model: function() {
    return Trade.ValidationRule.find();
  }
});
