Species.TaxonConceptLegalController = Ember.Controller.extend Species.SignedInStatus,
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

    showFullNote: (title, fullNote, nomenclatureNote) ->
      $("#full-note-legal .title").text(title)
      note = fullNote

      if(!Ember.isNone(nomenclatureNote) && nomenclatureNote.length > 0)
        note = note  + '<br/><br/>' + nomenclatureNote

      $("#full-note-legal .content").html(note)
      $("#full-note-legal").show()
    close: () ->
      $("#full-note-legal").hide()
