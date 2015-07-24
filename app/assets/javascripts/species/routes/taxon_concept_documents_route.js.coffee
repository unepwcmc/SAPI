Species.TaxonConceptDocumentsRoute = Ember.Route.extend
  renderTemplate: ->
    @getDocuments()
    @render('taxon_concept/documents')

  getDocuments: ->
    model = this.modelFor("taxonConcept")
    $.ajax(
      url: "/api/v1/documents?taxon_concept_id=" + model.get('id'),
      success: (data) ->
        model.set('cites_cop_docs', data.cites_cop_docs)
        model.set('ec_srg_docs', data.ec_srg_docs)
        model.set('cites_ac_docs', data.cites_ac_docs)
        model.set('cites_pc_docs', data.cites_pc_docs)
        model.set('other_docs', data.other_docs)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
    )
