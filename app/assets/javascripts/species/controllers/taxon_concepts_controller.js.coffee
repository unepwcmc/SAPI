Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner,
  needs: ['search']
  content: null
  page: 1
  perPage: 100
  #pages: null
  #showPageControls: null
  #showPrevPage: null
  #showNextPage: null

  contentObserver: ( ->
    meta = @get('content').meta
    #@pages = @set('getPages', meta)
    #@page = @set('@getPage', meta)
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
    total = @get('content').meta?.total
    if total
      p = Math.ceil(total / @perPage)
  ).observes("content.meta")

  page: ( ->
    page = @get('content').meta?.page
    if page 
      @set('page', page)
      return page
  ).property("content.meta")

  showPageControls: ( ->
    pages = @pages()
    if pages > 1 then return yes else return no
  ).property('content.meta')
  
  showPrevPage: ( ->
    page = @get('page')
    if page > 1 then return yes else return no
  ).property('content.meta')

  showNextPage: ( ->
    page = @get('page')
    if page < @pages then return yes else return no
  ).property('content.meta')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxon_concept.legal', m)
