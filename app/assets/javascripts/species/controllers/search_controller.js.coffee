Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
  geoEntityId: null
  geoEntityIds: null
  geoEntityAutoCompleteRegExp: null

  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []

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


  geoEntityAutoCompleteRegExpObserver: ( ->
    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      @get('geoEntityAutoCompleteRegExp').test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      @get('geoEntityAutoCompleteRegExp').test item.get('name')
  ).observes('geoEntityAutoCompleteRegExp')

  selectedGeoEntitiesObserver: ( ->
    @set 'geoEntityIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')