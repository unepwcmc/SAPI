Species.TaxonConceptController = Ember.ObjectController.extend
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
      "no_hover"
    else
      ""
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
