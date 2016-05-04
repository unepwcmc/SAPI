Species.DocumentTagLookup = Ember.Mixin.create
  selectedProposalOutcome: null
  selectedProposalOutcomeId: null
  selectedReviewPhase: null
  selectedReviewPhaseId: null

  initDocumentTagsSelectors: ->
    if @get('selectedProposalOutcomeId')
      po = @get('controllers.documentTags.proposalOutcomes').findBy('id', @get('selectedProposalOutcomeId'))
      @set('selectedProposalOutcome', po)

  proposalOutcomeDropdownVisible: ( ->
    @get('selectedDocumentType.id') == 'Document::Proposal'
  ).property('selectedDocumentType')

  actions:
    handleProposalOutcomeSelection: (proposalOutcome) ->
      @set('selectedProposalOutcome', proposalOutcome)

    handleProposalOutcomeDeselection: (proposalOutcome) ->
      @set('selectedProposalOutcome', null)
