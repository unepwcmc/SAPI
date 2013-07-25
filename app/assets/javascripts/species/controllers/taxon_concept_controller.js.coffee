Species.TaxonConceptController = Ember.ObjectController.extend
  needs: ['search']
  anyHistoricCitesListings: ( ->
    if @get('citesListings') != undefined && @get('citesListings').findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesListings')
  anyHistoricEuListings: ( ->
    if @get('euListings') != undefined && @get('euListings').findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('euListings')
  anyHistoricCitesQuotas: ( ->
    if @get('citesQuotas') != undefined && @get('citesQuotas').findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesQuotas')
  anyHistoricCitesSuspensions: ( ->
    if @get('citesSuspensions') != undefined && @get('citesSuspensions').findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesSuspensions')
  anyNonConventionCommonNames: ( ->
    if @get('commonNames') != undefined && @get('commonNames').findProperty('convention_language', false) != undefined
      "show_more"
    else
      ""
  ).property('commonNames')
  currentCitesListings: (->
    @get('citesListings').filterProperty('is_current', true)
  ).property('citesListings')
  historicCitesListings: (->
    @get('citesListings').filterProperty('is_current', false)
  ).property('citesListings')
  currentCitesQuotas: (->
    @get('citesQuotas').filterProperty('is_current', true)
  ).property('citesQuotas')
  historicCitesQuotas: (->
    @get('citesQuotas').filterProperty('is_current', false)
  ).property('citesQuotas')
  currentCitesSuspensions: (->
    @get('citesSuspensions').filterProperty('is_current', true)
  ).property('citesSuspensions')
  historicCitesSuspensions: (->
    @get('citesSuspensions').filterProperty('is_current', false)
  ).property('citesSuspensions')
  currentEuListings: (->
    @get('euListings').filterProperty('is_current', true)
  ).property('euListings')
  historicEuListings: (->
    @get('euListings').filterProperty('is_current', false)
  ).property('euListings')
  anyNonConventionLanguage: ( ->
    if @get('commonNames') == undefined
      return
    if @get('commonNames').findProperty('convention_language', false) == undefined
      ""
    else
      "show_more"
  ).property('commonNames')
  contentObserver: ( ->
    matchedOnSelf = true
    unless @get('controllers.search.taxonConceptQueryRe') == null
      matchedOnSelf = @get('controllers.search.taxonConceptQueryRe').test(@get('fullName'))
    @set('matchedOnSelf', matchedOnSelf)
  ).observes('content.didLoad')
  matchedOnSynonym: ( ->
    if @get('synonyms') == undefined || @get('matchedOnSelf') || @get('controllers.search.taxonConceptQueryRe') == null
      return null
    @get('synonyms').find((item) =>
      @get('controllers.search.taxonConceptQueryRe').test(item.full_name)
    )
  ).property('matchedOnSelf', 'synonyms')
  matchedOnSubspecies: ( ->
    if @get('subspecies') == undefined || @get('matchedOnSelf') || @get('controllers.search.taxonConceptQueryRe') == null
      return null
    @get('subspecies').find((item) =>
      @get('controllers.search.taxonConceptQueryRe').test(item.full_name)
    )
  ).property('matchedOnSelf', 'subspecies')
  matchInfo: ( -> 
    unless @get('matchedOnSelf') 
      if @get('matchedOnSynonym') != undefined
        '<i>' + @get('matchedOnSynonym.full_name') + '</i> is a synonym of <i>' + @get('fullName') +
        '</i>. You have been redirected to the species page for <i>' +
        @get('fullName') + '</i>.'
      else if @get('matchedOnSubspecies') != undefined
        '<i>' + @get('matchedOnSubspecies.full_name') + '</i> is a subspecies of <i>' + @get('fullName') +
        '</i>. You have been redirected to the species page for <i>' +
        @get('fullName') + '</i>.'
  ).property('matchedOnSelf', 'matchedOnSynonym', 'matchedOnSubspecies')
  searchFor: (query) ->
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      taxon_concept_query: query
    })
