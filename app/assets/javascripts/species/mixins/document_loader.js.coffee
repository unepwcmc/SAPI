Species.DocumentLoader = Ember.Mixin.create
  euSrgDocuments: {}
  citesCopProposalsDocuments: {}
  citesAcDocuments: {}
  citesPcDocuments: {}
  otherDocuments: {}

  euSrgDocsIsLoading: true
  citesCopProposalsDocsIsLoading: true
  citesAcDocsIsLoading: true
  citesPcDocsIsLoading: true
  otherDocsIsLoading: true

  euSrgDocsLoadMore: ( ->
    @get('euSrgDocuments.docs.length') < @get('euSrgDocuments.meta.total')
  ).property('euSrgDocuments.docs.length', 'euSrgDocuments.meta.total')

  citesCopProposalsDocsLoadMore: ( ->
    @get('citesCopProposalsDocuments.docs.length') < @get('citesCopProposalsDocuments.meta.total')
  ).property('citesCopProposalsDocuments.docs.length', 'citesCopProposalsDocuments.meta.total')

  citesAcDocsLoadMore: ( ->
    @get('citesAcDocuments.docs.length') < @get('citesAcDocuments.meta.total')
  ).property('citesAcDocuments.docs.length', 'citesAcDocuments.meta.total')

  citesPcDocsLoadMore: ( ->
    @get('citesPcDocuments.docs.length') < @get('citesPcDocuments.meta.total')
  ).property('citesPcDocuments.docs.length', 'citesPcDocuments.meta.total')

  otherDocsLoadMore: ( ->
    @get('otherDocuments.docs.length') < @get('otherDocuments.meta.total')
  ).property('otherDocuments.docs.length', 'otherDocuments.meta.total')

  euSrgDocsObserver: ( ->
    @set('euSrgDocsIsLoading', false)
  ).observes('euSrgDocuments.docs.@each.didLoad')

  citesCopProposalsDocsObserver: ( ->
    @set('citesCopProposalsDocsIsLoading', false)
  ).observes('citesCopProposalsDocuments.docs.@each.didLoad')

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
    params

  getEventTypeKey: (eventType) ->
    key = switch eventType
      when 'CitesCop' then 'CitesCopProposals'
      when 'CitesAc', 'CitesTc', 'CitesAc,CitesTc' then 'CitesAc'
      when 'CitesPc' then 'CitesPc'
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
