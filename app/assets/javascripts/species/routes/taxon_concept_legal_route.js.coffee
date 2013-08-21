Species.TaxonConceptLegalRoute = Ember.Route.extend
  renderTemplate: ->
    @render('taxon_concept/legal')
  # When the route is activated, reload the data. Hummmm...
  activate: ->
    taxonConcept = @modelFor('taxonConcept')
    if taxonConcept.get('taxonomy') is undefined
      @modelFor('taxonConcept').reload()

