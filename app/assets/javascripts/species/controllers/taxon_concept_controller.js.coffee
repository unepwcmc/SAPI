Species.TaxonConceptController = Ember.ObjectController.extend
  historicCitesListings: ( ->
    if @get('citesListings') == undefined
      return
    if @get('citesListings').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('citesListings')
  noCurrentCitesListings: ( ->
    if @get('citesListings') == undefined
      return
    if @get('citesListings').findProperty('is_current', true) == undefined
      return true
    else
      return false
  ).property("citesListings")
  historicEuListings: ( ->
    if @get('euListings') == undefined
      return
    if @get('euListings').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('euListings')
  noCurrentEuListings: ( ->
    if @get('euListings') == undefined
      return
    if @get('euListings').findProperty('is_current', true) == undefined
      return true
    else
      return false
  ).property("euListings")
  historicCitesQuotas: ( ->
    if @get('citesQuotas') == undefined
      return
    if @get('citesQuotas').findProperty('is_current', false) == undefined
      ""
    else
      "show_more"
  ).property('citesQuotas')
  noCurrentCitesQuotas: ( ->
    if @get('citesQuotas') == undefined
      return
    if @get('citesQuotas').findProperty('is_current', true) == undefined
      return true
    else
      return false
  ).property("citesQuotas")
  historicCitesSuspensions: ( ->
    if @get('citesSuspensions') == undefined
      return
    if @get('citesSuspensions').findProperty('is_current', false) == undefined
      "no_hover"
    else
      ""
  ).property('citesSuspensions')
  noCurrentCitesSuspensions: ( ->
    if @get('citesSuspensions') == undefined
      return
    if @get('citesSuspensions').findProperty('is_current', true) == undefined
      return true
    else
      return false
  ).property("citesSuspensions")
