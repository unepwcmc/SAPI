Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.TaxonConceptAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts']
  autoCompleteTaxonConcept: null

  actions:
    openSearchPage:->
      if @get('autoCompleteTaxonConcept')
        query = @get('autoCompleteTaxonConcept.fullName')
      else
        query = @get('taxonConceptQueryForDisplay')
      @transitionToRoute('documents', {queryParams: {
        taxon_concept_query: query
      }})

    handleTaxonConceptAutoCompleteSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)

