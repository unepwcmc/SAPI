Species.TaxonConceptNamesController = Ember.Controller.extend
  needs: 'taxonConcept'

  commonNamesExpanded: false

  actions:
    expandList: (id, flag) ->
      this.set(flag, true)
      $('#'+id).
        find('.historic').show('slow')

    contractList: (id, flag) ->
      this.set(flag, false)
      $('#'+id).
        find('.historic').hide('slow')
