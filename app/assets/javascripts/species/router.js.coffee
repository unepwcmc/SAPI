Species.Router.map (match) ->
  @resource 'taxonConcepts', { path: "/taxon_concepts" }
  @resource 'taxonConcept', { path: "/taxon_concepts/:taxon_concept_id" }, () ->
    @route 'legal'
    @route 'names'
    @route 'distribution'
    @route 'references'
    @route 'documents'
  @route 'elibrary'
  @resource 'documents'
  @route 'about'

Species.Router.reopen
  didTransition: (infos) ->
    @_super(infos);

    if window.ga
      Em.run.next ->
        ga('send', 'pageview', {
           'page': window.location.hash,
           'title': window.location.hash
        })
    return unless window._gaq
    Em.run.next ->
      _gaq.push(['_trackPageview', window.location.hash])
