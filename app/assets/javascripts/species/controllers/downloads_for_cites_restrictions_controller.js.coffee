Species.DownloadsForCitesRestrictionsController = Ember.Controller.extend
  designation: 'cites'

  needs: ['geoEntities','higherTaxaCitesEu']

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
  timeScopeIsCurrent: ( ->
    @get('timeScope') == 'current'
  ).property('timeScope')
  years: [1975..2013]
  selectedYears: []

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
    @set 'autoCompleteTaxonConcepts', @get('higherTaxaController.contentByRank')
    .map((e) =>
      {
        rankName: e.rankName
        taxonConcepts: e.taxonConcepts.filter((item) =>
          re.test item.get('fullName')
        )
      }
    ).filter((e) ->
      e.taxonConcepts.length > 0
    )
  ).observes('taxonConceptQuery')

  regionsObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteRegions', @get('controllers.geoEntities.regions'))
    )
  ).observes('controllers.geoEntities.regions.@each')

  countriesObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteCountries', @get('controllers.geoEntities.countries'))
    )
  ).observes('controllers.geoEntities.countries.@each')

  higherTaxaObserver: ( ->
    Ember.run.once(@, () ->
      @set('autoCompleteTaxonConcepts', @get('higherTaxaController.contentByRank'))
    )
  ).observes('higherTaxaController.contentByRank.@each')

  selectedGeoEntitiesObserver: ( ->
    @set 'selectedGeoEntitiesIds', @get('selectedGeoEntities').mapProperty('id')
  ).observes('selectedGeoEntities.@each')

  selectedTaxonConceptsObserver: ( ->
    @set 'selectedTaxonConceptsIds', @get('selectedTaxonConcepts').mapProperty('id')
  ).observes('selectedTaxonConcepts.@each')

  toParams: ( ->
    {
      data_type: 'CitesSuspensions' #TODO Quotas
      filters: 
        designation: @get('designation')
        geo_entities_ids: @get('selectedGeoEntitiesIds')
        higher_taxa_ids: @get('selectedTaxonConceptsIds')
        set: @get('timeScope')
        years: @get('selectedYears')
    }
  ).property(
    'selectedGeoEntitiesIds.@each', 'selectedTaxonConceptsIds.@each', 
    'timeScope', 'years.@each'
  )

  downloadUrl: ( ->
    '/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')
