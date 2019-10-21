Species.SearchController = Ember.Controller.extend Species.Spinner,
  Species.SearchContext,
  Species.TaxonConceptAutoCompleteLookup,
  Species.GeoEntityAutoCompleteLookup,
  Species.CustomTransition,
  needs: ['geoEntities', 'taxonConcepts']
  geoEntities: Ember.computed.alias("controllers.geoEntities")
  searchContext: 'species'
  taxonomy: 'cites_eu'
  redirected: false

  setFilters: (filtersHash) ->
    @set('taxonomy', filtersHash.taxonomy)
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])
    @initForm()

  openSearchPage: (taxonFullName, page, perPage) ->
    $("fieldset.taxon-search").removeClass('parent-focus parent-active')
    if taxonFullName == undefined
      query = @get('taxonConceptQueryForDisplay')
    else
      query = taxonFullName

    queryParams = {
      taxonomy: @get('taxonomy')
      taxon_concept_query: query
      geo_entities_ids: @get('selectedGeoEntities').mapProperty('id')
      geo_entity_scope: if @get('taxonomy') == 'cms'
        'cms'
      else
        'cites'
      page: page or 1
    }

    @customTransitionToRoute('taxonConcepts', { queryParams: queryParams })

  openTaxonPage: (taxonConceptId) ->
    @set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @customTransitionToRoute('taxonConcept.legal', m, {queryParams: false})

  actions:
    openSearchPage: (taxonFullName, page, perPage) ->
      @openSearchPage(taxonFullName, page, perPage)

    openTaxonPage: (taxonConceptId) ->
      @openTaxonPage(taxonConceptId)

    redirectToOpenSearchPage: (params) ->
      for property, val of params
        @set(property, val)
      @openSearchPage()

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      rankName = autoCompleteTaxonConcept.get('rankName')
      if rankName == 'SPECIES' || rankName == 'SUBSPECIES'
        @openTaxonPage(autoCompleteTaxonConcept.id)
      else
        @openSearchPage(autoCompleteTaxonConcept.get('fullName'))
