Species.TaxonConceptLegalController = Ember.ArrayController.extend
  needs: 'taxonConcept'

  citesListingsExpanded: false
  euListingsExpanded: false
  citesSuspensionsExpanded: false
  citesQuotasExpanded: false

  expandList: (id, flag) ->
    this.set(flag, true)
    $('#'+id).
      find('.historic').show('fast')

  contractList: (id, flag) ->
    this.set(flag, false)
    $('#'+id).
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#"+id).offset().top
      , 500
