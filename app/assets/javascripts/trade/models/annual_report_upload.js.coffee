Trade.AnnualReportUpload = DS.Model.extend
  numberOfRows: DS.attr('number')
  pointOfView: DS.attr('string')
  tradingCountry: DS.belongsTo('Trade.GeoEntity', {key: 'trading_country_id'})
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
    ' uploaded on ' + @get('createdAt') + ' by TODO'
  ).property('numberOfRows', 'tradingCountry.name', 'pointOfView')

Trade.Adapter.map('Trade.AnnualReportUpload', {
  sandboxShipments: { embedded: 'always' }
  validationErrors: { embedded: 'load' }
})
