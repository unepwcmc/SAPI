Species.TaxonConceptNamesController = Ember.ArrayController.extend
  needs: 'taxonConcept'

  commonNamesExpanded: false

  expandCommonNames: () ->
    this.set('commonNamesExpanded', true)
    $('#common_names').
      find('.historic').show('fast')

  contractCommonNames: () ->
    this.set('commonNamesExpanded', false)
    $('#common_names').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#common_names").offset().top
      , 500

