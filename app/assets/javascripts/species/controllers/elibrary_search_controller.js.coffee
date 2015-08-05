Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.TaxonConceptAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts']


  actions:
    openSearchPage:->
      @transitionToRoute('documents')
