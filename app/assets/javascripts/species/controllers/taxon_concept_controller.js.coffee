Species.TaxonConceptController = Ember.ObjectController.extend
  historicCitesListings: ( ->
    if @get('citesListings') == undefined
      return
    if @get('citesListings').findProperty('is_current', false) is `undefined`
      ""
    else
      "show_more"
  ).property('citesListings')
  historicEuListings: ( ->
    if @get('euListings') == undefined
      return
    if @get('euListings').findProperty('is_current', false) is `undefined`
      ""
    else
      "show_more"
  ).property('euListings')

  historicCitesQuotas: ( ->
    if @get('citesQuotas') == undefined
      return
    if @get('citesQuotas').findProperty('is_current', false) is `undefined`
      ""
    else
      "show_more"
  ).property('citesQuotas')
  historicCitesSuspensions: ( ->
    if @get('citesSuspensions') == undefined
      return
    if @get('citesSuspensions').findProperty('is_current', false) is `undefined`
      "no_hover"
    else
      ""
  ).property('citesSuspensions')
