Species.Router.map (match) ->
  @route 'search', { path: 'search/:params' }
  @resource 'taxon_concept', { path: 'taxon_concepts/:taxon_concept_id' }, () ->
    @route 'names'
    @route 'distribution'
    @route 'references'
