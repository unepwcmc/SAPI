Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner,
  needs: ['geoEntities', 'taxonConcepts']


  actions:
    openSearchPage:->
      @transitionToRoute('documents')
