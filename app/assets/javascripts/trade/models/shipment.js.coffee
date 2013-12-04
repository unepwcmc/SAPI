Trade.Shipment = DS.Model.extend

  importerId: DS.attr('number')
  exporterId: DS.attr('number')
  termId: DS.attr('number')

  reporterType: DS.attr('string')

  appendix: DS.attr('string')
  taxonConceptId: DS.attr('number')
  taxonConcept: DS.belongsTo('Trade.TaxonConcept')
  term: DS.belongsTo('Trade.Term')
  quantity: DS.attr('string')
  unit: DS.belongsTo('Trade.Unit')
  importer: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'importedShipments'
  })
  exporter: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'exportedShipments'
  })
  countryOfOrigin: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'countryOfOriginShipments'
  })
  importPermitNumber: DS.attr('string')
  exportPermitNumber: DS.attr('string')
  countryOfOriginPermitNumber: DS.attr('string')
  purpose: DS.belongsTo('Trade.Purpose')
  source: DS.belongsTo('Trade.Source')
  year: DS.attr('string')
  warnings: DS.attr('array')
  # if this is true, backend will save record despite of warnings
  ignoreWarnings: DS.attr('boolean')
  propertyChanged: false

  errorsPresent: ( ->
    result = false
    keys = (k for own k of @get('errors'))
    (keys.filter (k) -> k != 'warnings').length > 0
  ).property('errors.@each')

  warningsPresent: ( ->
    @get('errors.warnings.length') > 0 && !@get('propertyChanged')
  ).property('errors.@each.warnings.@each', 'propertyChanged')

  warningsConfirmation: ( ->
    @get('warningsPresent') && !@get('errorsPresent')
  ).property('warningsPresent', 'errorsPresent')

  taxonConceptIdDidChange: ( ->
    if @get('taxonConceptId')
      @set('taxonConcept', Trade.TaxonConcept.find(@get('taxonConceptId')))
  ).observes('taxonConceptId')

  propertyDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('taxonConceptId', 'appendix', 'year',
  'term', 'unit', 'purpose', 'source', 'quantity',
  'importer', 'exporter', 'countryOfOrigin',
  'importPermitNumber', 'exportPermitNumber', 'countryOfOriginPermitNumber')

Trade.Adapter.map('Trade.Shipment', {
  taxonConcept: { embedded: 'load' }
})