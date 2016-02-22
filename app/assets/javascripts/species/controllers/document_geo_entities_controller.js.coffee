Species.DocumentGeoEntitiesController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  content: null
  regions: null
  countries: null

  load: ->
    unless @get('loaded')
      @set('content', Species.DocumentGeoEntity.find({geo_entity_types_set: 5}))

  reload: (taxonConceptQuery) ->
    @set('content',
      Species.DocumentGeoEntity.find({
        geo_entity_types_set: 5,
        taxon_concept_query: taxonConceptQuery
      })
    )

  handleLoadFinished: () ->
    @set('regions', [])
    @set('countries', @get('content'))
