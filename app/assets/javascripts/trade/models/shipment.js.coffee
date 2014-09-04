Trade.Shipment = DS.Model.extend

  importerId: DS.attr('number')
  exporterId: DS.attr('number')
  termId: DS.attr('number')

  reporterType: DS.attr('string')

  appendix: DS.attr('string')
  taxonConceptId: DS.attr('number')
  taxonConcept: DS.belongsTo('Trade.TaxonConcept')
  reportedTaxonConceptId: DS.attr('number')
  reportedTaxonConcept: DS.belongsTo('Trade.TaxonConcept')
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
  originPermitNumber: DS.attr('string')
  legacyShipmentNumber: DS.attr('string')
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
    @set('propertyChanged', true)
  ).observes('taxonConceptId')

  reportedTaxonConceptIdDidChange: ( ->
    if @get('reportedTaxonConceptId')
      @set('reportedTaxonConcept', Trade.TaxonConcept.find(@get('reportedTaxonConceptId')))
    @set('propertyChanged', true)
  ).observes('reportedTaxonConceptId')

  # for some reason you can't put all of the following into one observer
  # because as a result the record freezes in root.loaded.materializing.firstTime
  # and updating does not work thereafter
  appendixDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('appendix')

  yearDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('year')

  termDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('term')

  unitDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('unit')

  purposeDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('purpose')

  sourceDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('source')

  quantityDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('quantity')

  importerDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('importer')

  exporterDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('exporter')

  countryOfOriginDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('countryOfOrigin')

  reporterTypeDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('reporterType')

  importPermitNumberDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('importPermitNumber')

  exportPermitNumberDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('exportPermitNumber')

  originPermitNumberDidChange: ( ->
    @set('propertyChanged', true)
  ).observes('originPermitNumber')

Trade.Adapter.map('Trade.Shipment', {
  taxonConcept: { embedded: 'load' }
  reportedTaxonConcept: { embedded: 'load' }
})