Species.DocumentLoader = Ember.Mixin.create
  euSrgDocuments: {}
  citesCopProposalsDocuments: {}
  citesRSTDocuments: {}
  otherDocuments: {}

  euSrgDocsIsLoading: true
  citesCopProposalsDocsIsLoading: true
  citesRSTDocsIsLoading: true
  otherDocsIsLoading: true

  euSrgDocsLoadMore: ( ->
    @get('euSrgDocuments.docs.length') < @get('euSrgDocuments.meta.total')
  ).property('euSrgDocuments.docs.length', 'euSrgDocuments.meta.total')

  citesCopProposalsDocsLoadMore: ( ->
    @get('citesCopProposalsDocuments.docs.length') < @get('citesCopProposalsDocuments.meta.total')
  ).property('citesCopProposalsDocuments.docs.length', 'citesCopProposalsDocuments.meta.total')

  citesRSTDocsLoadMore: ( ->
    @get('citesRSTDocuments.docs.length') < @get('citesRSTDocuments.meta.total')
  ).property('citesRSTDocuments.docs.length', 'citesRSTDocuments.meta.total')

  otherDocsLoadMore: ( ->
    @get('otherDocuments.docs.length') < @get('otherDocuments.meta.total')
  ).property('otherDocuments.docs.length', 'otherDocuments.meta.total')

  euSrgDocsObserver: ( ->
    @set('euSrgDocsIsLoading', false)
  ).observes('euSrgDocuments.docs.@each.didLoad')

  citesCopProposalsDocsObserver: ( ->
    @set('citesCopProposalsDocsIsLoading', false)
  ).observes('citesCopProposalsDocuments.docs.@each.didLoad')

  citesRSTDocsObserver: ( ->
    @set('citesRSTDocsIsLoading', false)
  ).observes('citesRSTDocuments.docs.@each.didLoad')

  citesOtherDocsObserver: ( ->
    @set('otherDocsIsLoading', false)
  ).observes('otherDocuments.docs.@each.didLoad')

  loadDocuments: (params, onSuccess) =>
    $.ajax(
      url: "/api/v1/documents",
      data: params,
      success: (data) ->
        tmp = {
          docs: data.documents,
          meta: data.meta
        }
        onSuccess.call @, tmp
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
    )

  getSearchParams: (eventType) ->
    if @get('searchContext') == 'documents'
      params = @get('controllers.elibrarySearch').getFilters()
    else
      params = {
        taxon_concepts_ids: [@get('controllers.taxonConcept.id')],
      }
    params['event_type'] = eventType
    params['sort_col'] = @get('sortCol') || 'date'
    params['sort_dir'] = @get('sortDir') || 'desc'
    params

  getEventTypeKey: (eventType) ->
    key = switch eventType
      when 'CitesCop,CitesExtraordinaryMeeting' then 'CitesCopProposals'
      when 'CitesAc,CitesPc,CitesTc' then 'CitesRST'
      when 'EcSrg' then 'EuSrg'
      else 'Other'

  actions:
    loadMoreDocuments: (eventType) ->
      params = @getSearchParams(eventType)
      contextKey = @getEventTypeKey(eventType).camelize() + 'Documents'
      params['page'] = @get(contextKey + '.meta.page') + 1
      @loadDocuments(params, (documents) =>
        docsKey = contextKey + '.docs'
        docs = @get(docsKey).pushObjects(documents.docs)
        metaKey = contextKey + '.meta'
        @set(metaKey, documents.meta)
      )

    reorderDocuments: (eventType, sortCol, sortDir) ->
      @set('sortCol', sortCol)
      @set('sortDir', sortDir)
      contextKey = @getEventTypeKey(eventType).camelize() + 'Documents'
      params = @getSearchParams(eventType)
      params['page'] = 1
      @loadDocuments(params, (documents) =>
        docsKey = contextKey + '.docs'
        @set(docsKey, documents.docs)
        metaKey = contextKey + '.meta'
        @set(metaKey, documents.meta)
      )
