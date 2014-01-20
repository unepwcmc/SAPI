Trade.SandboxShipmentsController = Ember.ArrayController.extend
  needs: ['annualReportUpload', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null

  columns: [
    'appendix', 'speciesName',
    'termCode', 'quantity',  'unitCode',
    'tradingPartner', 'countryOfOrigin',
    'importPermit', 'exportPermit', 'originPermit',
    'purposeCode', 'sourceCode', 'year'
  ]

  allAppendices: [
    Ember.Object.create({id: 'I', name: 'I'}),
    Ember.Object.create({id: 'II', name: 'II'}),
    Ember.Object.create({id: 'III', name: 'III'}),
    Ember.Object.create({id: 'N', name: 'N'})
  ]
