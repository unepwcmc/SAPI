Species.TaxonConceptDocumentsRoute = Ember.Route.extend
  renderTemplate: ->
    @render('taxon_concept/documents')
    Ember.run.scheduleOnce('afterRender', @, () ->
      @getDocuments()
    )

  getDocuments: ->
    model = this.modelFor("taxonConcept")
    $.ajax(
      url: "/api/v1/documents?taxon_concepts_ids=" + model.get('id'),
      success: (data) ->
        model.set('cites_cop_docs', data.cites_cop.docs)
        model.set('ec_srg_docs', data.ec_srg.docs)
        model.set('cites_ac_docs', data.cites_ac.docs)
        model.set('cites_pc_docs', data.cites_pc.docs)
        model.set('other_docs', data.other.docs)
        model.transitionTo('loaded.saved')
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
    )
