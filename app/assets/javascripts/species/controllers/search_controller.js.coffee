Species.SearchController = Ember.Controller.extend
  needs: ['geoEntities', 'taxonConcepts']
  taxonomy: 'cites_eu'
  scientificName: null
  geoEntityId: null
  geoEntityIds: null
  geoEntityAutoCompleteRegExp: null

  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []

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


  geoEntityAutoCompleteRegExpObserver: ( ->
    @set('autoCompleteRegions', @get('controllers.geoEntities.regions').filter( (item, index, enumerable) =>
      (@get('geoEntityAutoCompleteRegExp').test(item.get('name')))
    ))
    @set('autoCompleteCountries', @get('controllers.geoEntities.countries').filter( (item, index, enumerable) =>
      (@get('geoEntityAutoCompleteRegExp').test(item.get('name')))
    ))
  ).observes('geoEntityAutoCompleteRegExp')

  selectedGeoEntitiesObserver: ( ->
    @set('geoEntityIds', @get('selectedGeoEntities').mapProperty('id'))
  ).observes('selectedGeoEntities.@each')