Species.TaxonConceptController = Ember.ObjectController.extend Species.SearchContext,
  Species.SignedInStatus,
  needs: ['search', 'taxonConceptDocuments']
  searchContext: 'species'
  legalHeadings: [
    { id: 'cites_listings', name: 'CITES Listing', class: 'first' },
    { id: 'cites_quotas', name: 'CITES Quotas' },
    { id: 'cites_suspensions', name: 'CITES Suspensions' },
    { id: 'eu_listings', name: 'EU Listing' },
    { id: 'eu_decisions', name: 'EU Decisions', class: 'last' }
  ]

  actions: {
    scrollIntoView: (id) ->
      event.preventDefault()
      document.getElementById(id).scrollIntoView({ behavior: 'smooth' })
  }

  isCms: ( ->
    if @get('taxonomy') != undefined
      @get('taxonomy') == 'cms'
    else
      no
  ).property('taxonomy')
  isSubspecies: ( ->
    if @get('rankName') == 'SUBSPECIES' then yes else no
  ).property('rankName')
  hasSubspecies: ( ->
    if @get('subspecies').length > 0 then yes else no
  ).property('subspecies')
  isCmsAndHasNoNames: ( ->
    @get('taxonomy') != undefined and
      @get('taxonomy') == 'cms' and
      (@get('commonNames') == undefined or
      @get('commonNames').length == 0) and
      (@get('synonyms') == undefined or
      @get('synonyms').length == 0) and
      (@get('subspecies') == undefined or
      @get('subspecies').length == 0)
  ).property('taxonomy','commonNames','synonyms','subspecies')
  anyHistoricCmsListings: ( ->
    if @get('cmsListings') != undefined && @get('cmsListings')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('cmsListings')
  anyHistoricCitesListings: ( ->
    if @get('citesListings') != undefined && @get('citesListings')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesListings')
  anyHistoricEuListings: ( ->
    if @get('euListings') != undefined && @get('euListings')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('euListings')
  anyHistoricCitesQuotas: ( ->
    if @get('citesQuotas') != undefined && @get('citesQuotas')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesQuotas')
  anyHistoricCitesSuspensions: ( ->
    if @get('citesSuspensions') != undefined && @get('citesSuspensions')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('citesSuspensions')
  anyHistoricEuDecisions: ( ->
    if @get('euDecisions') != undefined && @get('euDecisions')
     .findProperty('is_current', false) != undefined
      "show_more"
    else
      ""
  ).property('euDecisions')
  anyNonConventionCommonNames: ( ->
    if @get('commonNames') != undefined && @get('commonNames')
     .findProperty('convention_language', false) != undefined
      "show_more"
    else
      ""
  ).property('commonNames')
  currentCmsListings: (->
    if @get('cmsListings') != undefined
      @get('cmsListings').filterProperty('is_current', true)
    else
      null
  ).property('cmsListings')
  historicCmsListings: (->
    if @get('cmsListings') != undefined
      @get('cmsListings').filterProperty('is_current', false)
    else
      null
  ).property('cmsListings')
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

  # This part is for the loading spinner...
  citesListingsIsLoading: ( ->
    if @get('citesListings') != undefined
      return no
    else
      return yes
  ).property('citesListings')
  citesQuotasIsLoading: ( ->
    if @get('citesQuotas') != undefined
      return no
    else
      return yes
  ).property('citesQuotas')
  euListingsIsLoading: ( ->
    if @get('euListings') != undefined
      return no
    else
      return yes
  ).property('euListings')
  citesSuspensionsIsLoading: ( ->
    if @get('citesSuspensions') != undefined
      return no
    else
      return yes
  ).property('citesSuspensions')

  contentObserver: ( ->
    matchedOnSelf = true
    if @get('controllers.search.redirected') == true && @get('controllers.search.taxonConceptQueryRe') != null
      matchedOnSelf = @get('controllers.search.taxonConceptQueryRe').test(@get('fullName'))
    @set('matchedOnSelf', matchedOnSelf)
    if @get('taxonomy')
      @set('controllers.search.taxonomy', @get('taxonomy'))
    if @get('fullName')
      @set('controllers.search.taxonConceptQueryForDisplay', @get('fullName'))
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

  hasNomenclatureNote: ( ->
    if @get('nomenclatureNoteEn') == null || @get('nomenclatureNoteEn').length <= 0 then no else yes
  ).property('nomenclatureNoteEn')

  nomenclatureChangesHappened: ( ->
    @get('nomenclatureNotification')
  ).property('nomenclatureNotification')

  actions:
    openSearchPage: (taxonFullName) ->
      @get("controllers.search").openSearchPage taxonFullName