Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner,
  needs: ['search', 'taxonConceptLink']
  content: null
  pages: null
  page: 1
  perPage: 100

  contentObserver: ( ->
    meta = @get('content').meta
    if meta != undefined &&  meta.total == 1
      @openTaxonPage(meta.higher_taxa_headers[0].taxon_concept_ids[0], true)
  ).observes("content.meta.didLoad")

  didContentLoad: ( ->
    c = @get('content.meta') != undefined
    s = $(@spinnerSelector)
    if c then s.css("visibility", "hidden") else s.css("visibility", "visible")
    c
  ).property('content.meta')

  setPages: ->
    total = @get('content').meta?.total
    if total
      pages = Math.ceil(total / @perPage)
      @set 'pages', pages
      return pages

  page: ( ->
    #page = @get('content.query.page')
    page = @get('content.meta.page') || 1
    if page 
      @set('page', page)
      return page
  ).property("content.meta")

  showPageControls: ( ->
    pages = @setPages()
    if pages > 1 then return yes else return no
  ).property('content.meta')
  
  showPrevPage: ( ->
    page = @get('page')
    if page > 1 then return yes else return no
  ).property('content.meta')

  showNextPage: ( ->
    page = @get('page')
    if page < @setPages() then return yes else return no
  ).property('content.meta')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxon_concept.legal', m)

  transitionToPage: (forward) ->
    if forward
      @set("page", parseInt(@page) + 1)
    else
      @set("page", parseInt(@page) - 1)
    @get("controllers.search").openSearchPage undefined, @page, @perPage

  actions:
    openTaxonPage: (taxonConceptId, redirected) ->
      @openTaxonPage(taxonConceptId, redirected)


