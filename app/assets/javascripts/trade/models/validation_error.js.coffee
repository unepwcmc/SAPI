Trade.ValidationError = DS.Model.extend
  errorMessage: DS.attr('string')
  errorCount: DS.attr('number')
  isPrimary: DS.attr('boolean')
  sandboxShipments: DS.hasMany('Trade.SandboxShipment')
  sandboxShipmentsIds: ( ->
    @get('sandboxShipments').mapBy('id')
  ).property('sandboxShipments.@each')
  ignoredValidationErrorId: DS.attr('number')

  isIgnored: ( ->
    @get('ignoredValidationErrorId')?
  ).property('ignoredValidationErrorId')
