Species.TaxonConceptDocumentsRoute = Ember.Route.extend Species.DocumentLoader,
  renderTemplate: ->
    @render('taxon_concept/documents')
    Ember.run.scheduleOnce('afterRender', @, () ->
      @getDocuments()
    )

  getDocuments: ->
    model = @modelFor("taxonConcept")
    controller = @controllerFor('taxonConceptDocuments')
    ['EcSrg', 'CitesCop', 'CitesAc', 'CitesPc', 'Other'].forEach((eventType) =>
      params = {
        event_type: eventType,
        taxon_concepts_ids: [model.get('id')]
      }
      eventTypeKey = eventType.camelize() + 'Documents'
      @loadDocuments(params, (documents) ->
        controller.set(eventTypeKey, documents)
      )
    )

