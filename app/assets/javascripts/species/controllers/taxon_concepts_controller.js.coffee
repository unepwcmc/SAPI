Species.TaxonConceptsController = Ember.ArrayController.extend
  needs: 'search'
  content: null

  contentObserver: ( ->
    # Here just to remind us that this can be done, if needed!
    if @get('content').meta != undefined &&  @get('content').meta.total == 1
      taxonConcept = Species.
        TaxonConcept.
        find(@get('content').meta.higher_taxa_headers[0].taxon_concept_ids[0])
      @transitionToRoute('taxon_concept.legal', taxonConcept)
  ).observes("content.meta.didLoad")

  customContent: null

  loopMyContent: ->
    test = []
    @content.forEach (e, i) ->
      t = {}
      t.id = e.id
      test.push t
    @set "customContent", test

  newTaxonSearch: (q) ->
    searchController = @get('controllers.search')
    @set('controllers.search.taxonConceptQuery', q)
    searchController.send('loadTaxonConcepts')

