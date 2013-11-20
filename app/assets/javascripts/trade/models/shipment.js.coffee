Trade.Shipment = DS.Model.extend

  importerId: DS.attr('string')
  exporterId: DS.attr('string')

  appendix: DS.attr('string')
  reportedAppendix: DS.attr('string')
  taxonConceptId: DS.attr('number')
  taxonConcept: DS.belongsTo('Trade.TaxonConcept')
  reportedSpeciesName: DS.attr('string')
  term: DS.belongsTo('Trade.Term')
  quantity: DS.attr('string')
  unit: DS.belongsTo('Trade.Unit')
  importer: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'importedShipments'
  })
  exporter: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'exportedShipments'
  })
  reporterType: DS.attr('string')
  countryOfOrigin: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'countryOfOriginShipments'
  })
  importPermitNumber: DS.attr('string')
  exportPermitNumber: DS.attr('string')
  countryOfOriginPermitNumber: DS.attr('string')
  purpose: DS.belongsTo('Trade.Purpose')
  source: DS.belongsTo('Trade.Source')
  year: DS.attr('string')
  _destroyed: DS.attr('boolean')

  taxonConceptIdDidChange: ( ->
    if @get('taxonConceptId')
      @set('taxonConcept', Trade.TaxonConcept.find(@get('taxonConceptId')))
  ).observes('taxonConceptId')

Trade.Adapter.map('Trade.Shipment', {
  taxonConcept: { embedded: 'load' }
})