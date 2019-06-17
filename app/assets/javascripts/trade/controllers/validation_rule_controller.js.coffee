Trade.ValidationRuleController = Ember.ObjectController.extend
  needs: ['validationRules']

  scopeArray: (->
    scope = @get('scope')
    
    return if Array.isArray(scope) then scope else []
  ).property('scope')