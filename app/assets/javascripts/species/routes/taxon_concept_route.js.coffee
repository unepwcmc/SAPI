Species.TaxonConceptRoute = Ember.Route.extend
  model: (params) ->
    Species.TaxonConcept.find(params.taxon_concept_id)
