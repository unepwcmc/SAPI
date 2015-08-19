Species.DocumentTagLookup = Ember.Mixin.create
  selectedProposalOutcome: null
  selectedProposalOutcomeId: null
  selectedReviewPhase: null
  selectedReviewPhaseId: null

  initDocumentTagsSelectors: ->
    if @get('selectedProposalOutcomeId')
      po = @get('controllers.documentTags.proposalOutcomes').findBy('id', @get('selectedProposalOutcomeId'))
      @set('selectedProposalOutcome', po)
    else if @get('selectedReviewPhaseId')
      rp = @get('controllers.documentTags.reviewPhases').findBy('id', @get('selectedReviewPhaseId'))
      @set('selectedReviewPhase', rp)
      @resetDocumentType

  proposalOutcomeDropdownVisible: ( ->
    @get('selectedDocumentType.id') == 'Document::Proposal'
  ).property('selectedDocumentType')

  reviewPhaseDropdownVisible: ( ->
    @get('selectedDocumentType.id') == 'Document::ReviewOfSignificantTrade'
  ).property('selectedDocumentType')

  actions:
    handleProposalOutcomeSelection: (proposalOutcome) ->
      @set('selectedProposalOutcome', proposalOutcome)

    handleProposalOutcomeDeselection: (proposalOutcome) ->
      @set('selectedProposalOutcome', null)

    handleReviewPhaseSelection: (reviewPhase) ->
      @set('selectedReviewPhase', reviewPhase)

    handleReviewPhaseDeselection: (reviewPhase) ->
      @set('selectedReviewPhase', null)
