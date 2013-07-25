Species.TaxonConceptController = Ember.ObjectController.extend
  needs: ['search']
  anyHistoricCitesListings: ( ->
    if @get('citesListings') == undefined
      return
    if @get('citesListings').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('citesListings')
  anyHistoricEuListings: ( ->
    if @get('euListings') == undefined
      return
    if @get('euListings').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('euListings')
  anyHistoricCitesQuotas: ( ->
    if @get('citesQuotas') == undefined
      return
    if @get('citesQuotas').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('citesQuotas')
  anyHistoricCitesSuspensions: ( ->
    if @get('citesSuspensions') == undefined
      return
    if @get('citesSuspensions').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('citesSuspensions')
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
  matchedOnSelf: ( ->
    return true if @get('controllers.search.taxonConceptQueryRe') == null
    @get('controllers.search.taxonConceptQueryRe').test(@get('fullName'))
  ).property('controllers.search.taxonConceptQueryRe')
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
        @get('matchedOnSynonym.full_name') + ' is a synonym of <i>' + @get('fullName') +
        '</i>. You have been redirected to the species page for <i>' +
        @get('fullName') + '</i>.'
      else if @get('matchedOnSubspecies') != undefined
        @get('matchedOnSubspecies.full_name') + ' is a subspecies of <i>' + @get('fullName') +
        '</i>. You have been redirected to the species page for <i>' +
        @get('fullName') + '</i>.'       
  ).property('matchedOnSelf', 'matchedOnSynonym', 'matchedOnSubspecies')
