Species.TaxonConceptController = Ember.ObjectController.extend
  historicCitesListings: ( ->
    if @get('citesListings') == undefined
      return
    if @get('citesListings').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property('citesListings')
  historicEuListings: ( ->
    if @get('euListings') == undefined
      return
    if @get('euListings').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property('euListings')
  historicCitesQuotas: ( ->
    if @get('quotas') == undefined
      return
    if @get('quotas').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property('quotas')
  historicCitesSuspensions: ( ->
    if @get('citesSuspensions') == undefined
      return
    if @get('citesSuspensions').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property('citesSuspensions')
