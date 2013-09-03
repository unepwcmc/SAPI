Species.Router.map (match) ->
  @route 'search', { path: 'search/:params' }
  @route 'about'
  @resource 'taxon_concept', { path: 'taxon_concepts/:taxon_concept_id' }, () ->
    @route 'legal'
    @route 'names'
    @route 'distribution'
    @route 'references'
