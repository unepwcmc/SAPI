Trade.AnnualReportUploadController = Ember.ObjectController.extend Trade.Flash,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes', 'sandboxShipments']
  content: null
  currentShipment: null
  filtersSelected: false
  sandboxShipmentsSubmitting: false

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
        sandbox_shipments_ids: @get('currentError.sandboxShipmentsIds')
        page: 1
      }
      @transitionToRoute('sandbox_shipments', {
        queryParams: params
      })
