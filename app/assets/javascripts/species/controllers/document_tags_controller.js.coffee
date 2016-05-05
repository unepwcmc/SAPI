Species.DocumentTagsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  needs: 'elibrarySearch'
  proposalOutcomes: null

  load: ->
    unless @get('loaded')
      @set('content', Species.DocumentTag.find())

  handleLoadFinished: () ->
    @set('proposalOutcomes', @get('content').filterProperty('type', 'DocumentTag::ProposalOutcome'))
    @get('controllers.elibrarySearch').initDocumentTagsSelectors()
