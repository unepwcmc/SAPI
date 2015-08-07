Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.SearchContext, Species.TaxonConceptAutoCompleteLookup, Species.GeoEntityAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts']
  searchContext: 'documents'
  autoCompleteTaxonConcept: null

  setFilters: (filtersHash) ->
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])

  actions:
    openSearchPage:->
      if @get('autoCompleteTaxonConcept') && @get('autoCompleteTaxonConcept.fullName') == @get('taxonConceptQueryForDisplay')
        query = @get('autoCompleteTaxonConcept.fullName')
      else
        query = @get('taxonConceptQueryForDisplay')
      @transitionToRoute('documents', {queryParams: {
        taxon_concept_query: query,
        geo_entities_ids: @get('selectedGeoEntities').mapProperty('id')
      }})

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
      @set('taxonConceptQueryForDisplay', autoCompleteTaxonConcept.get('fullName'))
