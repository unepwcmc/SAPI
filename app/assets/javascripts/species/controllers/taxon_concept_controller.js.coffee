Species.TaxonConceptController = Ember.ObjectController.extend
  historicCitesListings: ( ->
    if @get('citesListings').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property()
  historicEuListings: ( ->
    if @get('euListings').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property()
  historicCitesQuotas: ( ->
    if @get('quotas').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property()
  historicCitesSuspensions: ( ->
    if @get('citesSuspensions').findProperty('is_current', false) is `undefined`
      "empty"
    else
      ""
  ).property()
