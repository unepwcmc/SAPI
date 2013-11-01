Trade.Permit = DS.Model.extend
  number: DS.attr('string')
  importedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'importerPermit'
  })
  exportedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'exporterPermits'
  })
  originatedShipments: DS.hasMany('Trade.Shipment', {
    inverse: 'countryOfOriginPermit'
  })