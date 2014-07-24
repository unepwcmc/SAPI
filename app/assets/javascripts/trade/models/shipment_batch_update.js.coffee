Trade.ShipmentBatchUpdate = Ember.Object.extend
  taxonConceptId: null
  appendix: null
  year: null
  termId: null
  unitId: null
  purposeId: null
  sourceId: null
  importerId: null
  exporterId: null
  countryOfOriginId: null

  columns: (->
    [
      'taxonConceptId', 'appendix', 'year',
      'termId', 'unitId', 'purposeId', 'sourceId',
      'importerId', 'exporterId', 'countryOfOriginId',
      'importPermitNumber', 'exportPermitNumber', 'originPermitNumber', 'quantity'
    ]
  ).property()

  reset: ->
    @get('columns').forEach( (c) =>
      @set(c, null)
    )

  export: ->
    result = {}
    @get('columns').forEach( (c) =>
      result[c.decamelize()] = @get(c) if @get(c)
    )
    result

