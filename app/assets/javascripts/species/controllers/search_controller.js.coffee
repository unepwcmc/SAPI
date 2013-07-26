Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities']
  taxonomy: 'cites_eu'
  taxonConceptQuery: null
  taxonConceptsDropdownVisible: false
  geoEntityQuery: null
  geoEntityIds: null

  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []

  scientificName: ""

  loadTaxonConcepts: ->
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      taxon_concept_query: @get('taxonConceptQuery'),
    })

  setFilters: (filtersHash) ->
    @set('taxonomy', filtersHash.taxonomy)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)

  toParams: ->
    scientific_name: @get('scientificName')

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if !taxonConceptQuery || taxonConceptQuery.length < 3
      return;

    Species.TaxonConcept.find(
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

  regionsObserver: ( ->
    @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
  ).observes('controllers.geoEntities.regions.@each.didLoad')

  countriesObserver: ( ->
    @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))
  ).observes('controllers.geoEntities.countries.@each.didLoad')

  selectedGeoEntitiesObserver: ( ->
    @set 'geoEntityIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')