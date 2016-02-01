Species.DocumentLoader = Ember.Mixin.create
  ecSrgDocuments: {}
  citesCopDocuments: {}
  citesAcDocuments: {}
  citesPcDocuments: {}
  otherDocuments: {}

  ecSrgDocsIsLoading: true
  citesCopDocsIsLoading: true
  citesAcDocsIsLoading: true
  citesPcDocsIsLoading: true
  otherDocsIsLoading: true

  ecSrgDocsLoadMore: ( ->
    @get('ecSrgDocuments.docs.length') < @get('ecSrgDocuments.meta.total')
  ).property('ecSrgDocuments.docs.length', 'ecSrgDocuments.meta.total')

  citesCopDocsLoadMore: ( ->
    @get('citesCopDocuments.docs.length') < @get('citesCopDocuments.meta.total')
  ).property('citesCopDocuments.docs.length', 'citesCopDocuments.meta.total')

  citesAcDocsLoadMore: ( ->
    @get('citesAcDocuments.docs.length') < @get('citesAcDocuments.meta.total')
  ).property('citesAcDocuments.docs.length', 'citesAcDocuments.meta.total')

  citesPcDocsLoadMore: ( ->
    @get('citesPcDocuments.docs.length') < @get('citesPcDocuments.meta.total')
  ).property('citesPcDocuments.docs.length', 'citesPcDocuments.meta.total')

  otherDocsLoadMore: ( ->
    @get('otherDocuments.docs.length') < @get('otherDocuments.meta.total')
  ).property('otherDocuments.docs.length', 'otherDocuments.meta.total')

  ecSrgDocsObserver: ( ->
    @set('ecSrgDocsIsLoading', false)
  ).observes('ecSrgDocuments.docs.@each.didLoad')

  citesCopDocsObserver: ( ->
    @set('citesCopDocsIsLoading', false)
  ).observes('citesCopDocuments.docs.@each.didLoad')

  citesAcDocsObserver: ( ->
    @set('citesAcDocsIsLoading', false)
  ).observes('citesAcDocuments.docs.@each.didLoad')

  citesPcDocsObserver: ( ->
    @set('citesPcDocsIsLoading', false)
  ).observes('citesPcDocuments.docs.@each.didLoad')

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

  actions:
    loadMoreDocuments: (eventType) ->
      params = @getSearchParams(eventType)
      contextKey = eventType.camelize() + 'Documents'
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
      contextKey = eventType.camelize() + 'Documents'
      params = @getSearchParams(eventType)
      params['page'] = 1
      @loadDocuments(params, (documents) =>
        docsKey = contextKey + '.docs'
        @set(docsKey, documents.docs)
        metaKey = contextKey + '.meta'
        @set(metaKey, documents.meta)
      )