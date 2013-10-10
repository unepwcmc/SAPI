Trade.AnnualReportUploadController = Ember.ObjectController.extend
  content: null
  sandboxShipmentsSaving: ( ->
    @get('content.isSaving')
  ).property('content.isSaving')
  sandboxShipmentsSubmitting: false

  tableController: Ember.computed ->
    controller = Ember.get('Trade.SandboxShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content.sandboxShipments')
    controller
  .property()

  unsavedChanges: (->
    @get('content.isDirty')
  ).property('content.isDirty')

  allValuesFor: (attr) ->
    @get('content.sandboxShipments').mapBy(attr).compact().uniq()

  allAppendixValues: (->
    @allValuesFor('appendix')
  ).property('content.sandboxShipments.@each.appendix')
  selectedAppendixValues: []
  blankAppendix: false
  allSpeciesNameValues: (->
    @allValuesFor('speciesName')
  ).property('content.sandboxShipments.@each.speciesName')
  selectedSpeciesNameValues: []
  blankSpeciesName: false
  allTermCodeValues: (->
    @allValuesFor('termCode')
  ).property('content.sandboxShipments.@each.termCode')
  selectedTermCodeValues: []
  blankTermCode: false
  allQuantityValues: (->
    @allValuesFor('quantity')
  ).property('content.sandboxShipments.@each.quantity')
  selectedQuantityValues: []
  blankQuantity: false
  allUnitCodeValues: (->
    @allValuesFor('unitCode')
  ).property('content.sandboxShipments.@each.unitCode')
  selectedUnitCodeValues: []
  blankUnitCode: false
  allTradingPartnerValues: (->
    @allValuesFor('tradingPartner')
  ).property('content.sandboxShipments.@each.tradingPartner')
  selectedTradingPartnerValues: []
  blankTradingPartner: false
  allCountryOfOriginValues: (->
    @allValuesFor('countryOfOrigin')
  ).property('content.sandboxShipments.@each.countryOfOrigin')
  selectedCountryOfOriginValues: []
  blankCountryOfOrigin: false
  allImportPermitValues: (->
    @allValuesFor('importPermit')
  ).property('content.sandboxShipments.@each.importPermit')
  selectedImportPermitValues: []
  blankImportPermit: false
  allExportPermitValues: (->
    @allValuesFor('exportPermit')
  ).property('content.sandboxShipments.@each.exportPermit')
  selectedExportPermitValues: []
  blankExportPermit: false
  allOriginPermitValues: (->
    @allValuesFor('originPermit')
  ).property('content.sandboxShipments.@each.originPermit')
  selectedOriginPermitValues: []
  blankOriginPermit: false
  allPurposeCodeValues: (->
    @allValuesFor('purposeCode')
  ).property('content.sandboxShipments.@each.purposeCode')
  selectedPurposeCodeValues: []
  blankPurposeCode: false
  allSourceCodeValues: (->
    @allValuesFor('sourceCode')
  ).property('content.sandboxShipments.@each.sourceCode')
  selectedSourceCodeValues: []
  blankSourceCode: false
  allYearValues: (->
    @allValuesFor('year')
  ).property('content.sandboxShipments.@each.year')
  selectedYearValues: []
  blankYear: false

  filtersVisible: true
  updatesVisible: ( ->
    !@get('filtersVisible')
  ).property('filtersVisible')

  filtersChanged: ( ->
    shipments = @get('content.sandboxShipments')
    @get('columnNames').forEach (columnName) =>
      capitalisedColumnName = @capitaliseFirstLetter(columnName)
      selectedValuesName = 'selected' + capitalisedColumnName + 'Values'
      blankValue = 'blank' + capitalisedColumnName
      if @get(selectedValuesName + '.length') > 0 || @get(blankValue)
        shipments = shipments.filter((element) =>
          return @get(selectedValuesName).contains(element.get(columnName)) ||
            @get(blankValue) && (
              # check if null, undefined or blank
              !element.get(columnName) || /^\s*$/.test(element.get(columnName))
            )
        )
    @set('tableController.shipments', shipments)
  ).observes(
    'selectedAppendixValues.@each', 'blankAppendix',
    'selectedSpeciesNameValues.@each', 'blankSpeciesName',
    'selectedTermCodeValues.@each', 'blankTermCode',
    'selectedQuantityValues.@each', 'blankQuantity',
    'selectedUnitCodeValues.@each', 'blankUnitCode',
    'selectedTradingPartnerValues.@each', 'blankTradingPartner',
    'selectedCountryOfOriginValues.@each', 'blankCountryOfOrigin',
    'selectedImportPermitValues.@each', 'blankImportPermit',
    'selectedExportPermitValues.@each', 'blankExportPermit',
    'selectedOriginPermitValues.@each', 'blankOriginPermit',
    'selectedPurposeCodeValues.@each', 'blankPurposeCode',
    'selectedSourceCodeValues.@each', 'blankSourceCode',
    'selectedYearValues.@each', 'blankYear'
  )

  resetFilters: ->
    @get('columnNames').forEach (columnName) =>
      selectedValuesName = 'selected' + @capitaliseFirstLetter(columnName) + 'Values'
      @set(selectedValuesName, [])

  capitaliseFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  columnNames: ( ->
    @get('tableController.columnNames')
  ).property('tableController.columnNames')

  actions:
    submitShipments: ()->
      if @get('content.isDirty')
        alert "You have unsaved changes, please save those before submitting your shipments"
      else
        @set('sandboxShipmentsSubmitting', true)
        $.post '/trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
          'json'
        .done( =>
          @set('sandboxShipmentsSubmitting', false)
        )
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

    deleteSelection: () ->
      currentShipments = @get('tableController.shipments')
      currentShipments.forEach (shipment) ->
        shipment.set('_destroyed', true)
      @set('tableController.shipments', currentShipments)

    updateSelection: () ->
      valuesToUpdate = {'_modified': true}
      @get('columnNames').forEach (columnName) =>
        el = $('.sandbox-form').find('input[type=text][name=' + columnName + ']')
        blank = $('.sandbox-form').find('input[type=checkbox][name=' + columnName + ']:checked')
        valuesToUpdate[columnName] = el.val() if el && el.val()
        valuesToUpdate[columnName] = null if blank.length > 0
      currentShipments = @get('tableController.shipments')
      currentShipments.forEach (shipment) ->
        shipment.setProperties(valuesToUpdate)
      @set('tableController.shipments', currentShipments)

    selectForUpdate: () ->
      @set('filtersVisible', false)

    cancelSelectForUpdate: () ->
      $('#transformations').find('input[type=text]').val(null)
      @set('filtersVisible', true)
