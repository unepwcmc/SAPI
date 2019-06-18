Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend
  queryParams: {
    validation_error_id: { refreshModel: true },
    page: { refreshModel: true }
  }

  beforeModel: ->
    $('.loading-shipments').show()

  model: (params, transition) ->
    queryParams = params.queryParams
    
    @annualReportUpload = @modelFor('annualReportUpload')
    Trade.ValidationError.find(queryParams.validation_error_id).then((validationError) =>
      @validationError = validationError
      Trade.SandboxShipment.find(queryParams)
    , (validationError) =>
      @transitionTo('annual_report_upload', @annualReportUpload)
    )

  setupController: (controller, model) ->
    controller.set('model', model)
    @controllerFor('annualReportUpload').set('currentError', @validationError)
    @controllerFor('annualReportUpload').set('allErrorsCollapsed', true)

  actions:
    queryParamsDidChange: (changed, totalPresent, removed) ->
      @refresh()