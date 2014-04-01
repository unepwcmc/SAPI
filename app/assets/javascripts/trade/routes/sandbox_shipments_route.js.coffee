Trade.SandboxShipmentsRoute = Trade.BeforeRoute.extend
  queryParams: {
    sandbox_shipments_ids: { refreshModel: true },
    page: { refreshModel: true }
  }

  model: (params, transition) ->
    Trade.SandboxShipment.find(params)
