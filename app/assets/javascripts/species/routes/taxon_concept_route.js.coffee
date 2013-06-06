Species.TaxonConceptRoute = Ember.Route.extend
  model: (params) ->
    return Species.TaxonConcept.find(params.taxon_concept_id)
