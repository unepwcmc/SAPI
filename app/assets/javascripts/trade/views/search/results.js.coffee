Trade.SearchResultsView = Ember.View.extend
  templateName: 'trade/search/results'

  didInsertElement: ->
    # without this bit expect hilarious effects when mousing out of a tooltip
    # within a modal window
    $('.has-tooltip','.modal').tooltip().on('show', (e) ->
      e.stopPropagation()
    ).on('hidden', (e) ->
      e.stopPropagation()
    )

  columns: [
    {
      header: 'ID'
      displayProperty: 'id'
    },
    {
      header: 'Year'
      displayProperty: 'year'
    },
    {
      header: 'Appendix'
      displayProperty: 'appendix'
    },
    {
      header: 'Taxon Concept'
      displayProperty: 'taxonConcept.fullName'
    },
    {
      header: 'Rep. Taxon Concept'
      displayProperty: 'reportedTaxonConcept.fullName'
    },   
    {
      header: 'Term'
      displayProperty: 'term.code'
      longDisplayProperty: 'term.name'
    },
    {
      header: 'Quantity'
      displayProperty: 'quantity'
    },
    {
      header: 'Unit'
      displayProperty: 'unit.code'
      longDisplayProperty: 'unit.name'
    },
    {
      header: 'Importer'
      displayProperty: 'importer.isoCode2'
      longDisplayProperty: 'importer.name'
    },
    {
      header: 'Exporter'
      displayProperty: 'exporter.isoCode2'
      longDisplayProperty: 'exporter.name'
    },
    {
      header: 'Origin'
      displayProperty: 'countryOfOrigin.isoCode2'
      longDisplayProperty: 'countryOfOrigin.name'
    },
    {
      header: 'Purpose'
      displayProperty: 'purpose.code'
      longDisplayProperty: 'purpose.name'
    },
    {
      header: 'Source'
      displayProperty: 'source.code'
      longDisplayProperty: 'source.name'
    },
    {
      header: 'Reporter Type'
      displayProperty: 'reporterType'
    },
    {
      header: 'Import Permit'
      displayProperty: 'importPermitNumber'
    },
    {
      header: 'Export Permit'
      displayProperty: 'exportPermitNumber'
    },
    {
      header: 'Origin Permit'
      displayProperty: 'originPermitNumber'
    },
    {
      header: 'Legacy ID'
      displayProperty: 'legacyShipmentNumber'
    }
  ]

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no
