Species.TaxonConceptLegalController = Ember.ArrayController.extend
  needs: 'taxonConcept'

  citesListingsExpanded: false
  euListingsExpanded: false
  citesSuspensionsExpanded: false
  citesQuotasExpanded: false

  expandList: (id, flag) ->
    this.set(flag, true)
    $('#'+id).
      find('.historic').slideDown('slow')

  contractList: (id, flag) ->
    this.set(flag, false)
    $('#'+id).
      find('.historic').slideUp('slow')

