# The default behaviour of ember in the version we have is to find the model
# and find all its attributes, and then use that to filter json.errors, before
# setting modelInstance.errors (which becomes a DS.Errors object)
#
# This means views do not have access to errors on base or any associations.
# This hack overrides that behaviour.
#
# https://stackoverflow.com/questions/27713649/handling-validation-errors-in-ember-js
# https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/319
#
# ```js
# extractValidationErrors: function(type, json) {
#   var errors = {};
#
#   get(type, 'attributes').forEach(function(name) {
#     var key = this._keyForAttributeName(type, name);
#     if (json['errors'].hasOwnProperty(key)) {
#       errors[name] = json['errors'][key];
#     }
#   }, this);
#
#   return errors;
# }
# ```
DS.RESTSerializer.reopen
  extractValidationErrors: (type, json) ->
    if Object.values(type).includes('Trade.Shipment')
      json.errors
    else
      @_super(type, json)

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

  fieldErrorsByType: ( ->
    errorsByType = @get('errors')

    Object.keys(errorsByType || {}).reduce(
      (
        (acc, k) ->
          if 'warnings' != k
            acc[k] = errorsByType[k]

          acc
      ),
      {}
    )
  ).property('errors.@each')

  fieldErrors: ( ->
    fieldErrorsByType = @get('fieldErrorsByType')

    Object.keys(fieldErrorsByType).reduce(
      (
        (acc, k) ->
          acc.concat(
            (fieldErrorsByType[k] || []).map(
              (msg) ->
                k + ': ' + msg
            )
          )
      ),
      []
    )
  ).property('fieldErrorsByType.@each')

  fieldErrorsPresent: ( ->
    (k for own k of @get('fieldErrorsByType')).length > 0
  ).property('fieldErrorsByType.@each')

  warningsPresent: ( ->
    @get('errors.warnings.length') > 0
  ).property('errors.@each.warnings.@each')

  warningsConfirmation: ( ->
    @get('warningsPresent') && !@get('fieldErrorsPresent') && !@get('propertyChanged')
  ).property('warningsPresent', 'fieldErrorsPresent', 'propertyChanged')

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