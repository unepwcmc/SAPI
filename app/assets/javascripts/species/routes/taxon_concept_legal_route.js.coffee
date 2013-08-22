Species.TaxonConceptLegalRoute = Ember.Route.extend
  renderTemplate: ->
    @render('taxon_concept/legal')
  # When the route is activated, reload the data. Hummmm...
  activate: ->
    @modelFor('taxonConcept').reload()

