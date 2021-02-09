Trade.AnnualReportUploadController = Ember.ObjectController.extend Trade.Flash, Trade.AuthoriseUser, Trade.CustomTransition,
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes', 'sandboxShipments']
  content: null
  currentShipment: null
  filtersSelected: false
  sandboxShipmentsSubmitting: false

  init: ->
    transaction = @get('store').transaction()
    @set('transaction', transaction)

  capitaliseFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  actions:

    submitShipments: ->
      @userCanEdit( =>
        onSuccess = =>
          @set('sandboxShipmentsSubmitting', false)
          @customTransitionToRoute('search')
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
      )

    resetFilters: () ->
      @resetFilters()

    transitionToSandboxShipments: (error) ->
      @set('currentError', error)
      @notifyPropertyChange('allErrorsCollapsed')
      params = {
        validation_error_id: error.get('id')
        page: 1
      }
      @customTransitionToRoute('sandbox_shipments', @get('model'), {
        queryParams: params
      })

    toggleIgnoreValidationError: (validationError) ->
      oldIsIgnoredValue = validationError.get('isIgnored')
      validationError.set('isIgnored', !oldIsIgnoredValue)
      unless validationError.get('isSaving')
        transaction = @get('transaction')
        transaction.add(validationError)
        transaction.commit()
      validationError.one('didUpdate', this, ->
        if oldIsIgnoredValue
          @get('validationErrors').addObject(validationError)
          @get('ignoredValidationErrors').removeObject(validationError)
        else
          @get('ignoredValidationErrors').addObject(validationError)
          @get('validationErrors').removeObject(validationError)
      )
