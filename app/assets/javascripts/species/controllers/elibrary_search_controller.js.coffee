Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.TaxonConceptAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts']
  autoCompleteTaxonConcept: null

  actions:
    openSearchPage:->
      @transitionToRoute('documents')

    handleTaxonConceptAutoCompleteSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
