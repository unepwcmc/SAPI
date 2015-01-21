Species.SearchController = Ember.Controller.extend Species.Spinner,
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
  taxonConceptQueryForDisplay: null
  geoEntityQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedGeoEntitiesIds: []
  redirected: false

  setFilters: (filtersHash) ->
    @set('taxonomy', filtersHash.taxonomy)
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if not taxonConceptQuery or taxonConceptQuery.length < 3
      return;
    Species.AutoCompleteTaxonConcept.find(
      taxonomy: @get('taxonomy')
      taxon_concept_query: taxonConceptQuery
    )
  ).property('taxonConceptQuery')

  taxonConceptQueryRe: ( ->
    new RegExp("^"+@get('taxonConceptQuery'),"i")
  ).property('taxonConceptQuery')

  geoEntityQueryObserver: ( ->
    re = new RegExp(@get('geoEntityQuery'),"i")

    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')

    re = new RegExp("^[0-9]- "+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  geoEntitiesObserver: ( ->
    Ember.run.once(@, 'initForm')
  ).observes('controllers.geoEntities.@each.didLoad')

  initForm: ->
    @set('selectedGeoEntities', @get('controllers.geoEntities.content').filter((geoEntity) =>
      return geoEntity.get('id') in @get('selectedGeoEntitiesIds')
    ))
    @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
    @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))

  openSearchPage: (taxonFullName, page, perPage) ->
    $(".search fieldset").removeClass('parent-focus parent-active')
    if taxonFullName == undefined
      query = @get('taxonConceptQueryForDisplay')
    else
      query = taxonFullName
    # Resetting the page property if no page value has been passed.
    @transitionToRoute('taxonConcepts', {queryParams: {
      taxonomy: @get('taxonomy')
      taxon_concept_query: query
      geo_entities_ids: @get('selectedGeoEntities').mapProperty('id')
      geo_entity_scope: if @get('taxonomy') == 'cms'
        'cms'
      else
        'cites'
      page: page or 1
    }})

  openTaxonPage: (taxonConceptId) ->
    @set('redirected', false)
    $(".search fieldset").removeClass('parent-focus parent-active')
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxonConcept.legal', m, {queryParams:
      {taxon_concept_query: false, page: false}
    })

  actions:
    openSearchPage: (taxonFullName, page, perPage) ->
      @openSearchPage(taxonFullName, page, perPage)

    openTaxonPage: (taxonConceptId) ->
      @openTaxonPage(taxonConceptId)

    redirectToOpenSearchPage: (params) ->
      for property, val of params
        @set(property, val)
      @openSearchPage()

    deleteGeoEntitySelection: (context) ->
      @get('selectedGeoEntities').removeObject(context)