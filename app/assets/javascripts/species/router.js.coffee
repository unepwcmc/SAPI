Species.Router.map (match) ->
  @resource 'taxon_concepts'
  @resource 'taxon_concept', { path: 'taxon_concept/:taxon_concept_id' }
