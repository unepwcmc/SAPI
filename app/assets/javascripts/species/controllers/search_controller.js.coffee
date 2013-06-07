Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  scientificName: null
  geoEntityId: null

  autoCompleteRegions: null
  autoCompleteCountries: null

  loadTaxonConcepts: ->
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      scientific_name: @get('scientificName'),
      geo_entity_id: @get('geoEntityId')
    })

  setFilters: (filtersHash) ->
    @set('taxonomy', filtersHash.taxonomy)
    @set('scientificName', filtersHash.scientific_name)
    @set('geoEntityId', filtersHash.geo_entity_id)
