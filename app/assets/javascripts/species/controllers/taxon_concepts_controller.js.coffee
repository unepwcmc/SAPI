Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner,
  needs: ['search', 'taxonConceptLink']
  content: null
  perPage: 100

  contentObserver: ( ->
    meta = @get('content.meta')
    if meta != undefined &&  meta.total == 1
      @openTaxonPage(meta.higher_taxa_headers[0].taxon_concept_ids[0], true)
  ).observes("content.meta.didLoad")

  didContentLoad: ( ->
    c = @get('content.meta') != undefined
    s = $(@spinnerSelector)
    if c then s.css("visibility", "hidden") else s.css("visibility", "visible")
    c
  ).property('content.meta')

  pages: ( ->
    console.log(@get('content.meta'))
    total = @get('content.meta.total')
    if total
      Math.ceil(total / @perPage)
    else
      1
  ).property("content.meta.total")

  page: ( ->
    @get('content.meta.page') || 1
  ).property("content.meta.page")

  showPageControls: ( ->
    if @get('pages') > 1 then return yes else return no
  ).property('pages')

  showPrevPage: ( ->
    if @get('page') > 1 then return yes else return no
  ).property('page')

  showNextPage: ( ->
    if @get('page') < @get('pages') then return yes else return no
  ).property('page', 'pages')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxonConcept.legal', m, {queryParams:
      {taxon_concept_query: false, page: false}
    })

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@page) + 1
    else
      parseInt(@page) - 1
    @get("controllers.search").openSearchPage undefined, page, @perPage

  actions:
    openTaxonPage: (taxonConceptId, redirected) ->
      @openTaxonPage(taxonConceptId, redirected)


