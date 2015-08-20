Species.DocumentTagsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  needs: 'elibrarySearch'
  proposalOutcomes: null
  reviewPhases: null

  load: ->
    unless @get('loaded')
      @set('content', Species.DocumentTag.find())

  handleLoadFinished: () ->
    @set('proposalOutcomes', @get('content').filterProperty('type', 'DocumentTag::ProposalOutcome'))
    @set('reviewPhases', @get('content').filterProperty('type', 'DocumentTag::ReviewPhase'))
    @get('controllers.elibrarySearch').initDocumentTagsSelectors()
