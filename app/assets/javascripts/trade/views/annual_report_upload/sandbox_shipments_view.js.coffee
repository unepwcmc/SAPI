Trade.SandboxShipmentsView = Ember.View.extend
  templateName: 'trade/annual_report_upload/sandbox_shipments'

  columns: [

    {
      header: 'Appendix'
      displayProperty: 'appendix'
    },
    {
      header: 'Taxon Name'
      displayProperty: 'reportedTaxonName'
    },
    {
      header: 'Accepted Taxon Name'
      displayProperty: 'acceptedTaxonName'
    },
    {
      header: 'Term'
      displayProperty: 'termCode'
    },
    {
      header: 'Quantity'
      displayProperty: 'quantity'
    },
    {
      header: 'Unit'
      displayProperty: 'unitCode'
    },
    {
      header: 'Trading Partner'
      displayProperty: 'tradingPartner'
    },
    {
      header: 'Origin'
      displayProperty: 'countryOfOrigin'
    },
    {
      header: 'Import Permit'
      displayProperty: 'importPermit'
    },
    {
      header: 'Export Permit'
      displayProperty: 'exportPermit'
    },
    {
      header: 'Origin Permit'
      displayProperty: 'originPermit'
    },
    {
      header: 'Purpose'
      displayProperty: 'purposeCode'
    },
    {
      header: 'Source'
      displayProperty: 'sourceCode'
    },
    {
      header: 'Year'
      displayProperty: 'year'
    }
  ]

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no

  didInsertElement: ->
    $('.loading-shipments').hide()

  contentUpdated: ( ->
    $('.loading-shipments').hide()
  ).observes('controller.content.[]')
