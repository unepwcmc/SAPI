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
  anyHistoricEuDecisions: ( ->
    if @get('euDecisions') != undefined && @get('euDecisions').findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('euDecisions')
  anyNonConventionCommonNames: ( ->
    if @get('commonNames') != undefined && @get('commonNames').findProperty('convention_language', false) != undefined
      "show_more"
    else
      ""
  ).property('commonNames')
  currentCitesListings: (->
    if @get('citesListings') != undefined
      @get('citesListings').filterProperty('is_current', true)
    else
      null
  ).property('citesListings')
  historicCitesListings: (->
    if @get('citesListings') != undefined
      @get('citesListings').filterProperty('is_current', false)
    else
      null
  ).property('citesListings')
  currentCitesQuotas: (->
    if @get('citesQuotas') != undefined
      @get('citesQuotas').filterProperty('is_current', true)
    else
      null
  ).property('citesQuotas')
  historicCitesQuotas: (->
    if @get('citesQuotas') != undefined
      @get('citesQuotas').filterProperty('is_current', false)
    else
      null
  ).property('citesQuotas')
  currentCitesSuspensions: (->
    if @get('citesSuspensions') != undefined
      @get('citesSuspensions').filterProperty('is_current', true)
    else
      null
  ).property('citesSuspensions')
  historicCitesSuspensions: (->
    if @get('citesSuspensions') != undefined
      @get('citesSuspensions').filterProperty('is_current', false)
    else
      null
  ).property('citesSuspensions')
  currentEuListings: (->
    if @get('euListings') != undefined
      @get('euListings').filterProperty('is_current', true)
    else
      null
  ).property('euListings')
  historicEuListings: (->
    if @get('euListings') != undefined
      @get('euListings').filterProperty('is_current', false)
    else
      null
  ).property('euListings')
  currentEuDecisions: (->
    if @get('euDecisions') != undefined
      @get('euDecisions').filterProperty('is_current', true)
    else
      null
  ).property('euDecisions')
  historicEuDecisions: (->
    if @get('euDecisions') != undefined
      @get('euDecisions').filterProperty('is_current', false)
    else
      null
  ).property('euDecisions')
  contentObserver: ( ->
    matchedOnSelf = true
    if @get('controllers.search.redirected') == true && @get('controllers.search.taxonConceptQueryRe') != null
      matchedOnSelf = @get('controllers.search.taxonConceptQueryRe').test(@get('fullName'))
    @set('matchedOnSelf', matchedOnSelf)
    @get('content').reload()
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
