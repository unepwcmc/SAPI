Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null

  tableController: Ember.computed ->
    controller = Ember.get('Trade.SandboxShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content.sandboxShipments')
    controller
  .property()

  unsavedChanges: (->
    @get('content.isDirty')
  ).property('content.isDirty')

  allAppendixValues: (->
    @get('content.sandboxShipments').mapProperty('appendix').uniq()
  ).property('content.sandboxShipments.@each.appendix')
  selectedAppendixValues: []
  allSpeciesNameValues: (->
    @get('content.sandboxShipments').mapProperty('speciesName').uniq()
  ).property('content.sandboxShipments.@each.speciesName')
  selectedSpeciesNameValues: []
  allTermCodeValues: (->
    @get('content.sandboxShipments').mapProperty('termCode').uniq()
  ).property('content.sandboxShipments.@each.termCode')
  selectedTermCodeValues: [] 
  allQuantityValues: (->
    @get('content.sandboxShipments').mapProperty('quantity').uniq()
  ).property('content.sandboxShipments.@each.quantity')
  selectedQuantityValues: [] 
  allUnitCodeValues: (->
    @get('content.sandboxShipments').mapProperty('unitCode').uniq()
  ).property('content.sandboxShipments.@each.unitCode')
  selectedUnitCodeValues: [] 
  allTradingPartnerValues: (->
    @get('content.sandboxShipments').mapProperty('tradingPartner').uniq()
  ).property('content.sandboxShipments.@each.tradingPartner')
  selectedTradingPartnerValues: [] 
  allCountryOfOriginValues: (->
    @get('content.sandboxShipments').mapProperty('countryOfOrigin').uniq()
  ).property('content.sandboxShipments.@each.countryOfOrigin')
  selectedCountryOfOriginValues: [] 
  allImportPermitValues: (->
    @get('content.sandboxShipments').mapProperty('importPermit').uniq()
  ).property('content.sandboxShipments.@each.importPermit')
  selectedImportPermitValues: [] 
  allExportPermitValues: (->
    @get('content.sandboxShipments').mapProperty('exportPermit').uniq()
  ).property('content.sandboxShipments.@each.exportPermit')
  selectedExportPermitValues: [] 
  allOriginPermitValues: (->
    @get('content.sandboxShipments').mapProperty('originPermit').uniq()
  ).property('content.sandboxShipments.@each.originPermit')
  selectedOriginPermitValues: [] 
  allPurposeCodeValues: (->
    @get('content.sandboxShipments').mapProperty('purposeCode').uniq()
  ).property('content.sandboxShipments.@each.purposeCode')
  selectedPurposeCodeValues: [] 
  allSourceCodeValues: (->
    @get('content.sandboxShipments').mapProperty('sourceCode').uniq()
  ).property('content.sandboxShipments.@each.sourceCode')
  selectedSourceCodeValues: [] 
  allYearValues: (->
    @get('content.sandboxShipments').mapProperty('year').uniq()
  ).property('content.sandboxShipments.@each.year')
  selectedYearValues: [] 

  filtersChanged: ( ->
    shipments = @get('content.sandboxShipments')
    @get('tableController.columnNames').forEach( (columnName) =>
      selectedValuesName = 'selected' + @capitaliseFirstLetter(columnName) + 'Values'
      if @get(selectedValuesName + '.length') > 0
        shipments = shipments.filter((element) =>
          return @get(selectedValuesName).contains(element.get(columnName))
        )
    )
    @set('tableController.shipments', shipments)
  ).observes('selectedAppendixValues.@each', 'selectedSpeciesNameValues.@each',
    'selectedTermCodeValues.@each', 'selectedQuantityValues.@each',
    'selectedUnitCodeValues.@each', 'selectedTradingPartnerValues.@each',
    'selectedTradingPartnerValues.@each', 'selectedCountryOfOriginValues.@each',
    'selectedImportPermitValues.@each', 'selectedExportPermitValues.@each',
    'selectedOriginPermitValues.@each', 'selectedPurposeCodeValues.@each',
    'selectedSourceCodeValues.@each', 'selectedYearValues.@each')

  resetFilters: ->
    @set('selectedAppendixValues', [])
    @set('selectedSpeciesNameValues', [])
    @set('selectedTermCodeValues', [])

  capitaliseFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)
  
  actions:
    submitShipments: ()->
      $.post '/trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
        console.log(data)
        'json'
      @transitionToRoute('annual_report_uploads')

    setVisibleShipments: (shipments) ->
      @resetFilters()
      @set('tableController.shipments', shipments)

    saveChanges: () ->
      @get('store').commit()
      @transitionToRoute('annual_report_upload', @get('content'))

    cancelChanges: () ->
      if (!@get('content').get('isSaving'))
        @get('content').get('transaction').rollback() 

    resetFilters: () ->
      @resetFilters()
      @set('tableController.shipments', @get('content.sandboxShipments'))
