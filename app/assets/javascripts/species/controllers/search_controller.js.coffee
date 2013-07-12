Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
  geoEntityQuery: null
  geoEntityId: null
  geoEntityIds: null
  geoEntityAutoCompleteRegExp: null

  #autoCompleteRegions: null
  #autoCompleteCountries: null

  selectedGeoEntities: []

  scientificName: ""

  loadTaxonConcepts: ->
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      taxon_concept_query: @get('taxonConceptQuery'),
      geo_entity_id: @get('geoEntityId')
    })

  setFilters: (filtersHash) ->
    @set('taxonomy', filtersHash.taxonomy)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('geoEntityId', filtersHash.geo_entity_id)

  toParams: ->
    scientific_name : this.get('scientificName')

  geoEntityAutoCompleteRegExp: ( ->
    console.log('hello')
    return new RegExp("^"+@get('geoEntityQuery'),"i")
  ).property('geoEntityQuery')

  autoCompleteRegions: ( ->
    return @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      @get('geoEntityAutoCompleteRegExp').test item.get('name')
  ).property('geoEntityAutoCompleteRegExp')

  autoCompleteCountries: ( ->
    return @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      @get('geoEntityAutoCompleteRegExp').test item.get('name')
  ).property('geoEntityAutoCompleteRegExp')

  # geoEntityAutoCompleteRegExpObserver: ( ->
  #   @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
  #   .filter (item, index, enumerable) =>
  #     @get('geoEntityAutoCompleteRegExp').test item.get('name')
  #   @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
  #   .filter (item, index, enumerable) =>
  #     @get('geoEntityAutoCompleteRegExp').test item.get('name')
  # ).observes('geoEntityAutoCompleteRegExp')

  selectedGeoEntitiesObserver: ( ->
    @set 'geoEntityIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')

  # taxonConceptQueryObserver: ( ->

  #   @set 'autoCompleteTaxonConcepts', Species.TaxonConcept.find({taxon_concept_query: @get('taxonConceptQuery')})
  # ).observes('taxonConceptQuery')

  autoCompleteTaxonConcepts: ( ->
    console.log(@get('taxonConceptQuery'))
    taxonConceptQuery = @get('taxonConceptQuery')
    if !taxonConceptQuery
      return;

    matches = Species.TaxonConcept.find(
      scientific_name: taxonConceptQuery,
      autocomplete: true
    )
    return matches

  ).property('taxonConceptQuery')
