Species.TaxonConceptsRoute = Ember.Route.extend
  model: ->
    Species.TaxonConcept.find()