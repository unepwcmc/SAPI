Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend

  model: (params, queryParams, transition) ->
    Trade.SandboxShipment.find(queryParams)
