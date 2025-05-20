Species.Router.map (match) ->
  @resource 'taxonConcepts', { path: "/taxon_concepts" }
  @resource 'taxonConcept', { path: "/taxon_concepts/:taxon_concept_id" }, () ->
    @route 'legal'
    @route 'names'
    @route 'distribution'
    @route 'references'
    @route 'documents'
  @route 'elibrary'
  @resource 'documents', {
    queryParams: [
      'taxon_concept_query', 'geo_entities_ids', 'title_query',
      'event_type', 'events_ids', 'document_type',
      'proposal_outcome_id', 'review_phase_id', 'general_subtype'
    ]
  }
  @route 'about'

Species.Router.reopen
  didTransition: (infos) ->
    @_super(infos);

    if window.analytics.gtag
      Em.run.next ->
        window.analytics.gtag('event', 'page_view', {
          page_title: window.location.hash, # should really be something better
          page_location: window.location.hash
        });
