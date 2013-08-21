Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner,
  needs: 'search'
  content: null

  contentObserver: ( ->
    if @get('content').meta != undefined &&  @get('content').meta.total == 1
      @openTaxonPage(@get('content').meta.higher_taxa_headers[0].taxon_concept_ids[0], true)
  ).observes("content.meta.didLoad")

  didContentLoad: ( ->
    c = @get('content.meta') != undefined
    s = $(@spinnerSelector)
    if c then s.css("visibility", "hidden") else s.css("visibility", "visible")
    c
  ).property('content.meta')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxon_concept.legal', m)
