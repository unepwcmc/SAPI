Trade.ValidationRulesRoute = Trade.BeforeRoute.extend
  model: () ->
    Trade.ValidationRule.find()
