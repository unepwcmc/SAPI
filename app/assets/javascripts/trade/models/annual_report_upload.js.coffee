Trade.AnnualReportUpload = DS.Model.extend
  numberOfRows: DS.attr('number')
  pointOfView: DS.attr('string')
  tradingCountry: DS.belongsTo('Trade.GeoEntity', {key: 'trading_country_id'})
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
  # TODO created_by
  # TODO updated_by
  sandboxShipments: DS.hasMany('Trade.SandboxShipment')
  validationErrors: DS.hasMany('Trade.ValidationError')
  isExporter: (->
  	@get('pointOfView') == 'E'
  ).property('pointOfView')

Trade.Adapter.map('Trade.AnnualReportUpload', {
  sandboxShipments: { embedded: 'always' }
  validationErrors: { embedded: 'load' }
})
