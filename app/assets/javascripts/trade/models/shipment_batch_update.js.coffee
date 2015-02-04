Trade.ShipmentBatchUpdate = Ember.Object.extend
  taxonConceptId: null
  reportedTaxonConceptId: null
  appendix: null
  year: null
  term: null
  unit: null
  purpose: null
  source: null
  importer: null
  exporter: null
  countryOfOrigin: null
  reporterType: null
  importPermitNumber: null
  exportPermitNumber: null
  originPermitNumber: null
  countryOfOriginBlank: false
  unitBlank: false
  sourceBlank: false
  purposeBlank: false
  importPermitNumberBlank: false
  exportPermitNumberBlank: false
  originPermitNumberBlank: false

  columns: (->
    [
      'taxonConceptId', 'reportedTaxonConceptId', 'appendix', 'year',
      'term', 'unit', 'purpose', 'source',
      'importer', 'exporter', 'countryOfOrigin', 'reporterType',
      'importPermitNumber', 'exportPermitNumber', 'originPermitNumber'
    ]
  ).property()

  nullableColumns: (->
    [
      'countryOfOrigin', 'unit', 'source', 'purpose',
      'importPermitNumber', 'exportPermitNumber', 'originPermitNumber'
    ]
  ).property()

  columnsToExportAsIds: (->
    [
      'term', 'unit', 'purpose', 'source',
      'importer', 'exporter', 'countryOfOrigin'
    ]
  ).property()

  reset: ->
    @get('columns').forEach( (c) =>
      @set(c, null)
      if @get('nullableColumns').contains(c)
        blankPropertyName = c + 'Blank'
        @set(blankPropertyName, false)
    )

  export: ->
    result = {}
    @get('columns').forEach( (c) =>
      propertyValue = @get(c)
      propertyNameForBackend = c.decamelize()
      if @get('columnsToExportAsIds').contains(c)
        propertyNameForBackend += '_id'
      if propertyValue
        if @get('columnsToExportAsIds').contains(c)
          propertyValue = propertyValue.get('id')
        result[propertyNameForBackend] = propertyValue
      if @get('nullableColumns').contains(c)
        blankPropertyName = c + 'Blank'
        if @get(blankPropertyName)
          result[propertyNameForBackend] = null
    )
    result

