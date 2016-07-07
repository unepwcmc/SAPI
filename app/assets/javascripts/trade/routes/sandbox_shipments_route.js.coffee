Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend
  queryParams: {
    validation_error_id: { refreshModel: true },
    page: { refreshModel: true }
  }

  model: (params, transition) ->
    Trade.SandboxShipment.find(params)
