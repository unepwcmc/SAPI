Species.Router.map (match) ->
  @route 'search', { path: 'search/:params' }
  @route 'taxon_concepts', { path: 'taxon_concepts/:params' }
  @resource 'taxon_concept', { path: 'taxon_concepts/:taxon_concept_id' }

