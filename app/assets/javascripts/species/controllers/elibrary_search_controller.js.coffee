Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.TaxonConceptAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts']
  autoCompleteTaxonConcept: null

  setFilters: (filtersHash) ->
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)

  actions:
    openSearchPage:->
      if @get('autoCompleteTaxonConcept') && @get('autoCompleteTaxonConcept.fullName') == @get('taxonConceptQueryForDisplay')
        query = @get('autoCompleteTaxonConcept.fullName')
      else
        query = @get('taxonConceptQueryForDisplay')
      @transitionToRoute('documents', {queryParams: {
        taxon_concept_query: query
      }})

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
      @set('taxonConceptQueryForDisplay', autoCompleteTaxonConcept.get('fullName'))
