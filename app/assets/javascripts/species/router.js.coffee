Species.Router.map (match) ->
  @route 'search', { path: 'search/:params' }
  @route 'about'
  @resource 'taxon_concept', { path: 'taxon_concepts/:taxon_concept_id' }, () ->
    @route 'legal'
    @route 'names'
    @route 'distribution'
    @route 'references'

Species.Router.reopen
  didTransition: (infos) ->
    @_super(infos);
    # stuff for analytics.js
    # return unless window.ga
    # Em.run.next ->
    #   ga('send', 'pageview', {
    #      'page': window.location.hash,
    #      'title': window.location.hash
    #   })
    return unless window._gaq
    Em.run.next ->
      _gaq.push(['_trackPageview', window.location.hash])
