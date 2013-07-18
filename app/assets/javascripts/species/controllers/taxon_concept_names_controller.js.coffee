Species.TaxonConceptNamesController = Ember.ArrayController.extend
  needs: 'taxonConcept'

  commonNamesExpanded: false

  expandList: (id, flag) ->
    this.set(flag, true)
    $('#'+id).
      find('.historic').show('slow')

  contractList: (id, flag) ->
    this.set(flag, false)
    $('#'+id).
      find('.historic').hide('slow')
