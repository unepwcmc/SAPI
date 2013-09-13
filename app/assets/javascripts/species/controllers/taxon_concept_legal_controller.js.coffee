Species.TaxonConceptLegalController = Ember.ArrayController.extend
  needs: 'taxonConcept'

  citesListingsExpanded: false
  euListingsExpanded: false
  citesSuspensionsExpanded: false
  citesQuotasExpanded: false
  euDecisionsExpanded: false

  actions:
    expandList: (id, flag) ->
      this.set(flag, true)
      $('#'+id).
        find('.historic').slideDown('slow')

    contractList: (id, flag) ->
      this.set(flag, false)
      $('#'+id).
        find('.historic').slideUp('slow')

    showFullNote: (title, fullNote) ->
      $("#full-note-legal .title").text(title)
      $("#full-note-legal .content").html(fullNote)
      $("#full-note-legal").show()
    close: () ->
      $("#full-note-legal").hide()
