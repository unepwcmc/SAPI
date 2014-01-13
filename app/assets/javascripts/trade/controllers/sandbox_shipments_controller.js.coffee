Trade.SandboxShipmentsController = Ember.ArrayController.extend
  #needs: ['annualReportUpload']
  content: null
  visibleShipments: null

  sandboxShipmentsDidLoad: ( ->
    console.log 'sandboxShipmentsDidLoad'
  ).observes('visibleShipments')

  columns: [
    'appendix', 'speciesName',
    'termCode', 'quantity',  'unitCode',
    'tradingPartner', 'countryOfOrigin',
    'importPermit', 'exportPermit', 'originPermit',
    'purposeCode', 'sourceCode', 'year'
  ]

  codeMappings: {}

