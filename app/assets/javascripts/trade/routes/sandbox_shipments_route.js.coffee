Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend
  queryParams: {
    validation_error_id: { refreshModel: true },
    page: { refreshModel: true }
  }

  model: (params, transition) ->
    @validationError = Trade.ValidationError.find(params.validation_error_id)
    Trade.SandboxShipment.find(params)

  setupController: (controller, model) ->
    controller.set('model', model)
    @controllerFor('annualReportUpload').set('currentError', @validationError)
