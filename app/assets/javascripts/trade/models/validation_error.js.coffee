Trade.ValidationError = DS.Model.extend
  errorMessage: DS.attr('string')
  errorCount: DS.attr('number')
  errorSelector: DS.attr('hash')
  isPrimary: DS.attr('boolean')
  sandboxShipments: DS.hasMany('Trade.SandboxShipment')
