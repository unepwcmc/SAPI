Trade.AnnualReportUpload = DS.Model.extend
  numberOfRows: DS.attr('number')
  pointOfView: DS.attr('string')
  tradingCountry: DS.belongsTo('Trade.GeoEntity', {key: 'trading_country_id'})
  fileName: DS.attr('string')
  hasPrimaryErrors: DS.attr('boolean')
  createdAt: DS.attr('string')
  updatedAt: DS.attr('string')
  # TODO created_by
  # TODO updated_by
  sandboxShipments: DS.hasMany('Trade.SandboxShipment')
  validationErrors: DS.hasMany('Trade.ValidationError')

  summary: (->
    @get('tradingCountry.name') + ' (' + @get('pointOfView') + '), ' +
    @get('numberOfRows') + ' shipments ' +
    ' uploaded on ' + @get('createdAt') + ' by TODO (' +
    @get('fileName') + ')'
  ).property('numberOfRows', 'tradingCountry.name', 'pointOfView')

  hasErrors: (->
    @get('validationErrors.length') > 0
  ).property('validationErrors.length')

Trade.Adapter.map('Trade.AnnualReportUpload', {
  sandboxShipments: { embedded: 'always' }
  validationErrors: { embedded: 'load' }
})
