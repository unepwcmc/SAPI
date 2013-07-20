Species.DownloadsForEuDecisionsController = Ember.Controller.extend
  designation: 'eu'

  needs: ['geoEntities', 'higherTaxaCitesEu']

  higherTaxaController: ( ->
    @get('controllers.higherTaxaCitesEu')
  ).property()

  geoEntityQuery: null
  autoCompleteRegions: null
  autoCompleteCountries: null
  selectedGeoEntities: []
  selectedGeoEntitiesIds: []
  autoCompleteTaxonConcepts: []
  selectedTaxonConcepts: []
  selectedTaxonConceptsIds: []
  timeScope: 'current'
  years: [1975..2013]
  selectedYears: []
  positiveOpinions: true
  negativeOpinions: true
  noOpinions: true
  suspensions: true

  geoEntityOueryObserver: ( ->
    re = new RegExp("^"+@get('geoEntityQuery'),"i")

    @set 'autoCompleteRegions', @get('controllers.geoEntities.regions')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
    @set 'autoCompleteCountries', @get('controllers.geoEntities.countries')
    .filter (item, index, enumerable) =>
      re.test item.get('name')
  ).observes('geoEntityQuery')

  taxonConceptOueryObserver: ( ->
    re = new RegExp("^"+@get('taxonConceptQuery'),"i")

    @set 'autoCompleteTaxonConcepts', @get('higherTaxaController.content')
    .filter (item, index, enumerable) =>
      re.test item.get('fullName')
  ).observes('taxonConceptQuery')

  regionsObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
    )
  ).observes('controllers.geoEntities.regions.@each.didLoad')

  countriesObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))
    )
  ).observes('controllers.geoEntities.countries.@each.didLoad')

  higherTaxaObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteTaxonConcepts', @get('higherTaxaController.content'))
    )
  ).observes('higherTaxaController.content.@each.didLoad')

  autoCompleteTaxonConceptsByRank: ( ->
    ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY'].map((e) =>
      {
        rankName: e
        taxonConcepts: @get('autoCompleteTaxonConcepts').filterProperty('rankName', e)
      }
    ).filter((e) ->
      e.taxonConcepts.length > 0
    )
  ).property('autoCompleteTaxonConcepts.@each')


  selectedGeoEntitiesObserver: ( ->
    @set 'selectedGeoEntitiesIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')

  selectedTaxonConceptsObserver: ( ->
    @set 'selectedTaxonConceptsIds', @get('selectedTaxonConcepts').mapProperty('id')
  ).observes('selectedTaxonConcepts.@each')

  toParams: ( ->
    {
      data_type: 'EuDecisions'
      filters: 
        designation: @get('designation')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        higher_taxa_ids: @get('selectedTaxonConceptsIds')
        set: @get('timeScope')
        years: @get('selectedYears')
        positiveOpinions: @get('positiveOpinions')
        negativeOpinions: @get('negativeOpinions')
        noOpinions: @get('noOpinions')
        suspensions: @get('suspensions')
    }
  ).property(
    'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each', 
    'timeScope', 'years.@each', 'positiveOpinions', 'negativeOpinions',
    'noOpinions', 'suspensions'
  )

  downloadUrl: ( ->
    '/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')
