Trade.Shipment = DS.Model.extend
  appendix: DS.attr('string')
  reportedAppendix: DS.attr('string')
  taxonConcept: DS.belongsTo('Trade.TaxonConcept')
  reportedSpeciesName: DS.attr('string')
  term: DS.belongsTo('Trade.Term')
  quantity: DS.attr('string')
  unit: DS.belongsTo('Trade.Unit')
  importer: DS.belongsTo('Trade.GeoEntity')
  exporter: DS.belongsTo('Trade.GeoEntity')
  reporterType: DS.attr('string')
  countryOfOrigin: DS.belongsTo('Trade.GeoEntity')
  importPermit: DS.belongsTo('Trade.Permit')
  exportPermits: DS.hasMany('Trade.Permit')
  countryOfOriginPermit: DS.belongsTo('Trade.Permit')
  purpose: DS.belongsTo('Trade.Purpose')
  source: DS.belongsTo('Trade.Source')
  year: DS.attr('string')
  _destroyed: DS.attr('boolean')

Trade.Adapter.map('Trade.Shipment', {
  taxonConcept: { embedded: 'load' }
  importPermit: { embedded: 'load' }
  exportPermits: { embedded: 'load' }
  countryOfOriginPermit: { embedded: 'load' }
})