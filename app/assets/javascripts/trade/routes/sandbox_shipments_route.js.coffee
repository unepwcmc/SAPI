Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend Trade.Utils, 
  
  model: (params, queryParams, transition) ->
    Trade.SandboxShipment.find(queryParams)

  setupController: (controller, model, queryParams) ->

    @aru_controller = controller.get('controllers.annualReportUpload')
    error = @aru_controller
      .get('content.validationErrors')
      .find( (error) =>
        +queryParams.error_identifier == @hashCode error.get('errorMessage')
      )
    if error
      @aru_controller.set('errorMessage', error.get('errorMessage'))
    controller.set('model', model)
    controller.set('errorParams', queryParams)

  # Called when leaving this route
  deactivate: ->
    @aru_controller.set('errorMessage', "")
    @aru_controller = null

