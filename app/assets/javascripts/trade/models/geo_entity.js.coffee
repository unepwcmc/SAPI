Trade.GeoEntity = DS.Model.extend
  name: DS.attr('string')
  isoCode2: DS.attr('string')
  annualReportUploads: DS.hasMany('Trade.AnnualReportUpload', {
    inverse: 'tradingCountry'
  })
  importedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'importer'
  })
  exportedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'exporter'
  })
  countryOfOriginShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'countryOfOrigin'
  })