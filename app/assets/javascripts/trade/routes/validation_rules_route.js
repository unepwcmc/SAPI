Trade.ValidationRulesRoute = Ember.Route.extend({
  model: function() {
    console.log('hello');
    console.log(Trade.ValidationRule.find());
    return Trade.ValidationRule.find();
  }
});
