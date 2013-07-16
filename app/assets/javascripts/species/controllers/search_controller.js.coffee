Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
  taxonConceptsDropdownVisible: false
  geoEntityQuery: null
  geoEntityId: null
  geoEntityIds: null
  geoEntitiesDropdownVisible: false

  autoCompleteRegions: null
  autoCompleteCountries: null
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

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if !taxonConceptQuery || taxonConceptQuery.length < 3
      return;

    Species.TaxonConcept.find(
      taxonomy: @get('taxonomy')
      scientific_name: taxonConceptQuery
      autocomplete: true
    )
  ).property('taxonConceptQuery')

  geoEntityOueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  selectedGeoEntitiesObserver: ( ->
    @set 'geoEntityIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')
