Trade.GeoEntity = DS.Model.extend
  name: DS.attr('string')
  isoCode2: DS.attr('string')
  importedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'importer'
  })
  exportedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'exporter'
  })
  originatedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'countryOfOrigin'
  })