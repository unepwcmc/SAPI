Species.TaxonConceptLegalRoute = Ember.Route.extend
  renderTemplate: ->
    @render('taxon_concept/legal')

  afterModel: ->
    model = @modelFor('taxonConcept')
    # The `citesListings` field is a proxy for the model completeness.
    if model.get('id') and model.get('citesListings') == undefined
      model.reload()
    model

