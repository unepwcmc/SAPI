Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend

  model: (params, queryParams, transition) ->
    Trade.SandboxShipment.find(queryParams)

  # Called when leaving this route
  deactivate: ->
    @aru_controller.set('errorMessage', "")
    @aru_controller = null

