Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  scientificName: null
  geoEntity: null

  loadTaxonConcepts: ->
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      scientific_name: @get('scientificName'),
      geo_entity_id: @get('geoEntity.id')
    })

  setFilters: (filtersHash) ->
    console.log(filtersHash)
    @set('taxonomy', filtersHash.taxonomy)
    @set('scientificName', filtersHash.scientific_name)
    @set('geoEntity', filtersHash.geo_entity_id)
