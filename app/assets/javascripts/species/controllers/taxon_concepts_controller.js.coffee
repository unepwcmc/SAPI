Species.TaxonConceptsController = Ember.ArrayController.extend

  content: null


  contentObserver: ( ->
    
    # Does not work????
    #@content.set Species.TaxonConcept.FIXTURES
    #@content.forEach (c, i) -> console.log c

    #console.log 'looooo', @get "length"
    console.log @get "taxonConcepts"
    #@loopMyContent()


  ).observes("content.didLoad")


  customContent: ( -> 
    #[{n: 1}, {n: 2}, {n: 3}]

    t = []
    @forEach (e, i) ->
      t.push e
    t 
  ).property('@')


  loopMyContent: () ->
    console.log '##############', @get "length"
    @forEach (e, i) ->
      log e

