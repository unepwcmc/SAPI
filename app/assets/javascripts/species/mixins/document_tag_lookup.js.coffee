Species.DocumentTagLookup = Ember.Mixin.create
  selectedProposalOutcome: null
  selectedProposalOutcomeId: null

  initDocumentTagsSelectors: ->
    if @get('selectedProposalOutcomeId')
      po = @get('controllers.documentTags.proposalOutcomes').findBy('id', @get('selectedProposalOutcomeId'))
      @set('selectedProposalOutcome', po)

  proposalOutcomeDropdownVisible: ( ->
    @get('selectedEventType.id') == 'CitesCop'
  ).property('selectedEventType')

  actions:
    handleProposalOutcomeSelection: (proposalOutcome) ->
      @set('selectedProposalOutcome', proposalOutcome)

    handleProposalOutcomeDeselection: (proposalOutcome) ->
      @set('selectedProposalOutcome', null)
