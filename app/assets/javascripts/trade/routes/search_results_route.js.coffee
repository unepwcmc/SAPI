Trade.SearchResultsRoute = Trade.BeforeRoute.extend Trade.LoadingModal,
  Trade.CustomTransition

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
    searchResultsController = @controllerFor('search_results')
    mode = @getParameterByName('mode')

    if mode == 'edit'
      searchResultsController.send('editBatch')
    else if mode == 'delete'
      searchResultsController.send('deleteBatch')

    # So you can open the edit/delete modal again
    if mode
      window.history.replaceState({}, 'Search', @removeParam('mode', window.location.href))
    

  actions:
    dataChanged: () ->
      @customTransitionToRoute('search')
    queryParamsDidChange: (changed, totalPresent, removed) ->
      @refresh()
