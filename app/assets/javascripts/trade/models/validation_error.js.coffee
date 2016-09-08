Trade.ValidationError = DS.Model.extend
  errorMessage: DS.attr('string')
  errorCount: DS.attr('number')
  isPrimary: DS.attr('boolean')
  isIgnored: DS.attr('boolean')
