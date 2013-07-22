Species.TaxonConceptsController = Ember.ArrayController.extend
  needs: 'search'
  content: null

  contentObserver: ( ->
    # Here just to remind us that this can be done, if needed!
    #@loopMyContent()
  ).observes("content.didLoad")

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

