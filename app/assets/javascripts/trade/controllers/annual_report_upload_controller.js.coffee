Trade.AnnualReportUploadController = Ember.ObjectController.extend Trade.Flash,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes', 'sandboxShipments']
  content: null
  visibleShipments: []
  currentShipment: null
  filtersSelected: false

  sandboxShipmentsDidLoad: ( ->
    @set('visibleShipments', @get('content.sandboxShipments'))
    @set('sandboxShipmentsLoaded', true)
  ).observes('content.sanboxShipments.@each.didLoad')

  sandboxShipmentsSubmitting: false

  selectedAppendixChanged: ( ->
    @applyFilter('appendix')
  ).observes('selectedAppendixValues.@each', 'blankAppendix')

  selectedTaxonNameChanged: ( ->
    @applyFilter('taxonName')
  ).observes('selectedTaxonNameValues.@each', 'blankTaxonName')

  selectedTermCodeChanged: ( ->
    @applyFilter('termCode')
  ).observes('selectedTermCodeValues.@each', 'blankTermCode')

  selectedQuantityChanged: ( ->
    @applyFilter('quantity')
  ).observes('selectedQuantityValues.@each', 'blankQuantity')

  selectedUnitCodeChanged: ( ->
    @applyFilter('unitCode')
  ).observes('selectedUnitCodeValues.@each', 'blankUnitCode')

  selectedTradingPartnerChanged: ( ->
    @applyFilter('tradingPartner')
  ).observes('selectedTradingPartnerValues.@each', 'blankTradingPartner')

  selectedCountryOfOriginChanged: ( ->
    @applyFilter('countryOfOrigin')
  ).observes('selectedCountryOfOriginValues.@each', 'blankCountryOfOrigin')

  selectedImportPermitChanged: ( ->
    @applyFilter('importPermit')
  ).observes('selectedImportPermitValues.@each', 'blankImportPermit')

  selectedExportPermitChanged: ( ->
    @applyFilter('exportPermit')
  ).observes('selectedExportPermitValues.@each', 'blankExportPermit')

  selectedOriginPermitChanged: ( ->
    @applyFilter('originPermit')
  ).observes('selectedOriginPermitValues.@each', 'blankOriginPermit')

  selectedPurposeCodeChanged: ( ->
    @applyFilter('purposeCode')
  ).observes('selectedPurposeCodeValues.@each', 'blankPurposeCode')

  selectedSourceCodeChanged: ( ->
    @applyFilter('sourceCode')
  ).observes('selectedSourceCodeValues.@each', 'blankSourceCode')

  selectedYearChanged: ( ->
    @applyFilter('year')
  ).observes('selectedYearValues.@each', 'blankYear')

  applyFilter: (columnName) ->
    capitalisedColumnName = @capitaliseFirstLetter(columnName)
    selectedValuesName = 'selected' + capitalisedColumnName + 'Values'
    blankValue = 'blank' + capitalisedColumnName
    if @get(selectedValuesName + '.length') > 0 || @get(blankValue)
      @set('filtersSelected', true)
      shipments = @get('visibleShipments').filter((element) =>
        value = element.get(columnName)
        return @get(selectedValuesName).contains(value) ||
          # check if null, undefined or blank
          @get(blankValue) && (!value || /^\s*$/.test(value))
      )
      @set('visibleShipments', shipments)


  capitaliseFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  actions:

    submitShipments: ->
      onSuccess = => 
        @set('sandboxShipmentsSubmitting', false)
        @transitionToRoute('shipments', {queryParams: page: 1})
        @flashSuccess(message: "#{@get('numberOfRows')} shipments submitted.", persists: true)
      onError = (xhr, msg, error) =>
        @set('sandboxShipmentsSubmitting', false)
        @flashError(message: xhr.responseText)
      if @get('content.isDirty')
        alert "You have unsaved changes, please save those before submitting your shipments"
      else if @get('content.hasPrimaryErrors')
        alert "Primary errors detected, cannot submit shipments"
      else
        @set('sandboxShipmentsSubmitting', true)
      $.when($.ajax({
        type: "POST"
        url: "/trade/annual_report_uploads/#{@get('id')}/submit"
        data: {}
        dataType: 'json'
      })).then(onSuccess, onError)


    resetFilters: () ->
      @resetFilters()


    # new for sandbox shipments updateSelection
    transitionToSandboxShipments: (error) ->
      @set('currentError', error)
      params = {
        "sandbox_shipments_ids": error.get('sandboxShipments').mapBy("id")
        page: 1
      }
      @transitionToRoute('sandbox_shipments', {
        queryParams: params
      })
