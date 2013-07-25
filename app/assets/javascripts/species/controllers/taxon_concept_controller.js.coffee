Species.TaxonConceptController = Ember.ObjectController.extend
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
