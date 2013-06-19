Species.TaxonConceptsController = Ember.ArrayController.extend
  content: null

  contentObserver: ( ->

    # Does not work????
    #@content.set Species.TaxonConcept.FIXTURES
    #@content.forEach (c, i) -> console.log c

    #console.log 'looooo', @get "content.length"
    #console.log @get "taxonConcepts"
    #@loopMyContent()


  ).observes("content.didLoad")


  customContent: null

  loopMyContent: ->
    #console.log '##############', @get "content.length"
    test = []
    @content.forEach (e, i) ->
      t = {}
      t.id = e.id
      test.push t
    @set "customContent", test

