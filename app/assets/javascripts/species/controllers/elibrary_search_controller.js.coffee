Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.SearchContext,
  Species.TaxonConceptAutoCompleteLookup,
  Species.GeoEntityAutoCompleteLookup,
  Species.EventLookup,
  Species.DocumentTagLookup,
  needs: ['documentGeoEntities', 'taxonConcepts', 'events', 'documentTags']
  geoEntities: Ember.computed.alias("controllers.documentGeoEntities")
  searchContext: 'documents'
  autoCompleteTaxonConcept: null
  selectedEventType: null

  setFilters: (filtersHash) ->
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])
    if filtersHash.title_query == ''
      filtersHash.title_query = null
    @set('titleQuery', filtersHash.title_query)
    @set('selectedEventType', @get('controllers.events.eventTypes').findBy('id', filtersHash.event_type))
    @set('selectedEventId', filtersHash.event_id)
    allDocumentTypes = @get('controllers.events.documentTypes').concat @get('controllers.events.interSessionalDocumentTypes')
    @set('selectedDocumentType', allDocumentTypes.findBy('id', filtersHash.document_type))
    @set('selectedProposalOutcomeId', filtersHash.proposal_outcome_id)
    @set('selectedReviewPhaseId', filtersHash.review_phase_id)

  getFilters: ->
    if @get('taxonConceptQueryForDisplay') && @get('taxonConceptQueryForDisplay').length > 0
      taxonConceptQuery = @get('taxonConceptQueryForDisplay')
    if @get('titleQuery') && @get('titleQuery').length > 0
      titleQuery = @get('titleQuery')
    {
      taxon_concept_query: taxonConceptQuery,
      geo_entities_ids: @get('selectedGeoEntities').mapProperty('id'),
      title_query: titleQuery,
      event_type: @get('selectedEventType.id'),
      event_id: @get('selectedEvent.id'),
      document_type: @get('selectedDocumentType.id'),
      proposal_outcome_id: @get('selectedProposalOutcome.id'),
      review_phase_id: @get('selectedReviewPhase.id')
    }

  filteredDocumentTypes: ( ->
    if @get('selectedEventType')
      @get('controllers.events.documentTypes').filter (dt) =>
        return false unless dt.eventTypes
        dt.eventTypes.indexOf(@get('selectedEventType.id')) >= 0
    else
      @get('controllers.events.documentTypes')
  ).property('selectedEventType.id')

  interSessionalDocumentTypes: ( ->
    @get('controllers.events.interSessionalDocumentTypes')
  ).property()

  documentTypeDropdownVisible: ( ->
    @get('selectedEventType.id') == 'EcSrg'
  ).property('selectedEventType')

  interSessionalDocTypeDropdownVisible: ( ->
    !@get('selectedEventType.id')?
  ).property('selectedEventType')

  isSignedIn: ( ->
    $.cookie('speciesplus.signed_in') == '1'
  ).property()

  actions:
    openSearchPage:->
      @transitionToRoute('documents', {queryParams: @getFilters()})

    handleDocumentTypeSelection: (documentType) ->
      @set('selectedDocumentType', documentType)

    handleDocumentTypeDeselection:  ->
      @set('selectedDocumentType', null)

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
      @set('taxonConceptQueryForDisplay', autoCompleteTaxonConcept.get('fullName'))

    clearSearch: ->
      @set('taxonConceptQueryForDisplay', '')
      @set('taxonConceptQuery', '')
      @set('selectedGeoEntities', [])
      @set('titleQuery', '')
      @set('selectedEventType', null)
      @set('selectedEvent', null)
      @set('selectedEventId', null)
      @set('selectedDocumentType', null)
      @set('selectedInterSessionalDocType', null)
      @set('selectedProposalOutcome', null)
      @set('selectedReviewPhase', null)
