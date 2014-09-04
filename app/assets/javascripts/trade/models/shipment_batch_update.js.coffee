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

  columns: (->
    [
      'taxonConceptId', 'reportedTaxonConceptId', 'appendix', 'year',
      'term', 'unit', 'purpose', 'source',
      'importer', 'exporter', 'countryOfOrigin', 'reporterType'
    ]
  ).property()

  reset: ->
    @get('columns').forEach( (c) =>
      @set(c, null)
    )

  export: ->
    result = {}
    @get('columns').forEach( (c) =>
      property_value = @get(c)
      if property_value
        property_name = c.decamelize()
        if typeof property_value == 'object'
          result[property_name + '_id'] = property_value.get('id')
        else
          result[property_name] = property_value
    )
    result

