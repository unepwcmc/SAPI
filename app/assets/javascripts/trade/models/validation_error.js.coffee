Trade.ValidationError = DS.Model.extend
  errorMessage: DS.attr('string')
  errorCount: DS.attr('number')
