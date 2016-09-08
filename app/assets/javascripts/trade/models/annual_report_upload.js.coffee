Trade.AnnualReportUpload = DS.Model.extend
  numberOfRows: DS.attr('number')
  pointOfView: DS.attr('string')
  tradingCountry: DS.belongsTo('Trade.GeoEntity', {key: 'trading_country_id'})
  fileName: DS.attr('string')
  hasPrimaryErrors: DS.attr('boolean')
  createdAt: DS.attr('string')
  updatedAt: DS.attr('string')
  createdBy: DS.attr('string')
  updatedBy: DS.attr('string')
  sandboxShipments: DS.hasMany('Trade.SandboxShipment')
  validationErrors: DS.hasMany('Trade.ValidationError')
  ignoredValidationErrors: DS.hasMany('Trade.ValidationError', {key: 'ignored_validation_errors'})

  summary: (->
    @get('tradingCountry.name') + ' (' + @get('pointOfView') + '), ' +
    @get('numberOfRows') + ' shipments ' +
    ' uploaded on ' + @get('createdAt') + ' by ' + @get('createdBy') + ' (' +
    @get('fileName') + ')'
  ).property('numberOfRows', 'tradingCountry.name', 'pointOfView')

Trade.Adapter.map('Trade.AnnualReportUpload', {
  sandboxShipments: { embedded: 'always' }
  validationErrors: { embedded: 'load' }
  ignoredValidationErrors: { embedded: 'load' }
})
