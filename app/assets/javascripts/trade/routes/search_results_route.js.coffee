Trade.SearchResultsRoute = Trade.BeforeRoute.extend Trade.LoadingModal,

  queryParams: {
    taxon_concepts_ids: { refreshModel: true },
    reported_taxon_concepts_ids: { refreshModel: true },
    appendices: { refreshModel: true },
    time_range_start: { refreshModel: true },
    time_range_end: { refreshModel: true },
    terms_ids: { refreshModel: true },
    units_ids: { refreshModel: true },
    purposes_ids: { refreshModel: true },
    sources_ids: { refreshModel: true },
    importers_ids: { refreshModel: true },
    exporters_ids: { refreshModel: true },
    countries_of_origin_ids: { refreshModel: true },
    reporter_type: { refreshModel: true },
    permits_ids: { refreshModel: true },
    quantity: { refreshModel: true },
    unit_blank: { refreshModel: true },
    purpose_blank: { refreshModel: true },
    source_blank: { refreshModel: true },
    country_of_origin_blank: { refreshModel: true },
    permit_blank: { refreshModel: true },
    page: { refreshModel: true }
  }

  model: (params) ->
    queryParams = params.queryParams

    @showLoadingModal()
    Trade.Shipment.find(queryParams)

  afterModel: () ->
    @hideLoadingModal()

  actions:
    dataChanged: () ->
      @refresh()
    queryParamsDidChange: (changed, totalPresent, removed) ->
      @refresh()
