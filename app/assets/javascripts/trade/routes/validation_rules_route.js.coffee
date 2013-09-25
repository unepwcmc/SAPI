Trade.ValidationRulesRoute = Ember.Route.extend
  model: () ->
    Trade.ValidationRule.find()
