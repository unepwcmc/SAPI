Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner,
  needs: ['search']
  content: null
  #page: 1
  #perPage: 100
  #pages: null
  #showPageControls: null
  #showPrevPage: null
  #showNextPage: null

  contentObserver: ( ->
    console.log "----contentObserver-----"
    meta = @get('content').meta
    @pages = @set('getPages', meta)
    @page = @set('@getPage', meta)
    if meta != undefined &&  meta.total == 1
      @openTaxonPage(meta.higher_taxa_headers[0].taxon_concept_ids[0], true)
  ).observes("content.meta.didLoad")

  didContentLoad: ( ->
    console.log "xx-----didContentLoad----xx"
    c = @get('content.meta') != undefined
    s = $(@spinnerSelector)
    if c then s.css("visibility", "hidden") else s.css("visibility", "visible")
    c
  ).property('content.meta')

  stuff: ( ->
    console.log "Stuff has been called!"
  ).property('content.meta')

#  pages: ( ->
#    total = @get('content').meta?.total
#    console.log 'xxxxxxxxxxxxxxxx', total
#    #if total
#    #  p = Math.ceil(total / @perPage)
#    #  @set 'pages', p
#  ).observes("content.meta")
#
#  page: ( ->
#    page = @get('content').meta?.page
#    if page then return page
#  ).property("content.meta")
#
# showPageControls: ( ->
#   console.log '#####################', @pages
#   if @pages > 1 then yes else no
# ).property('pages')
#
#  showPrevPage: ( ->
#    if @page > 1 then yes else no
#  ).property('content.meta')
#
#  showNextPage: ( ->
#    if @page < @pages then yes else no
#  ).property('content.meta')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxon_concept.legal', m)
