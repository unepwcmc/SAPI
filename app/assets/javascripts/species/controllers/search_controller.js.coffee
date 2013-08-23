Species.SearchController = Ember.Controller.extend Species.Spinner,
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
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
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if !taxonConceptQuery || taxonConceptQuery.length < 3
      return;

    Species.AutoCompleteTaxonConcept.find(
      taxonomy: @get('taxonomy')
      taxon_concept_query: taxonConceptQuery
      ranks: ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS', 'SPECIES']
      autocomplete: true
    )
  ).property('taxonConceptQuery')

  taxonConceptQueryRe: ( ->
    new RegExp("^"+@get('taxonConceptQuery'),"i")
  ).property('taxonConceptQuery')

  geoEntityQueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
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

  openTaxonPage: (taxonConceptId) ->
    @set('redirected', false)
    $(".search fieldset").removeClass('parent-focus parent-active')
    m = Species.TaxonConcept.find(taxonConceptId)
    # Setting a spinner until content is loaded.
    $(@spinnerSelector).css("visibility", "visible")
    @transitionToRoute('taxon_concept.legal', m)

  openSearchPage: (taxonFullName, page, perPage) ->
    $(".search fieldset").removeClass('parent-focus parent-active')
    if taxonFullName == undefined
      query = @get('taxonConceptQuery')
    else
      query = taxonFullName
    # Resetting the page property if no page value has been passed.
    unless page then @get("controllers.taxonConcepts").set('page', 1)
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy')
      taxon_concept_query: query
      geo_entities_ids: @get('selectedGeoEntities').mapProperty('id')
      page: page or 1
      per_page: perPage or 100
    })

  redirectToOpenSearchPage: (params) ->
    for property, val of params
      @set(property, val)
    @openSearchPage()
