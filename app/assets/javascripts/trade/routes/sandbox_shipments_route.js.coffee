Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend
  queryParams: {
    validation_error_id: { refreshModel: true },
    page: { refreshModel: true }
  }

  beforeModel: ->
    @controllerFor('sandboxShipments').set('sandboxShipmentsLoading', true)

  model: (params, transition) ->
    @annualReportUpload = @modelFor('annualReportUpload')
    Trade.ValidationError.find(params.validation_error_id).then((validationError) =>
      @validationError = validationError
      Trade.SandboxShipment.find(params)
    , (validationError) =>
      @transitionTo('annual_report_upload', @annualReportUpload)
    )

  setupController: (controller, model) ->
    controller.set('model', model)
    @controllerFor('annualReportUpload').set('currentError', @validationError)
    @controllerFor('annualReportUpload').set('allErrorsCollapsed', true)
