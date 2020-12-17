Species.TaxonConceptDocumentsRoute = Ember.Route.extend Species.DocumentLoader,
  renderTemplate: ->
    @render('taxon_concept/documents')
    Ember.run.scheduleOnce('afterRender', @, () ->
      @getDocuments()
    )

  getDocuments: ->
    model = @modelFor("taxonConcept")
    controller = @controllerFor('taxonConceptDocuments')
    @get('eventTypes').forEach((eventType) =>
      params = {
        event_type: eventType,
        taxon_concepts_ids: [model.get('id')]
      }
      eventType = @getEventTypeKey(eventType).camelize()
      eventTypeKey = eventType + 'Documents'
      isLoadingProperty = eventType + 'DocsIsLoading'
      controller.set(isLoadingProperty, true)
      @loadDocuments(params, (documents) ->
        controller.set(eventTypeKey, documents)
      )
    )

