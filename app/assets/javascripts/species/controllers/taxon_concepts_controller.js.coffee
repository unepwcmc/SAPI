Species.TaxonConceptsController = Ember.ArrayController.extend
  needs: 'search'
  content: null

  contentObserver: ( ->
    if @get('content').meta != undefined &&  @get('content').meta.total == 1
      @get('controllers.search').set('redirected', true)
      @openTaxonPage(@get('content').meta.higher_taxa_headers[0].taxon_concept_ids[0])
  ).observes("content.meta.didLoad")

  openTaxonPage: (taxonConceptId) ->
    @transitionToRoute('taxon_concept.legal', Species.TaxonConcept.find(taxonConceptId))
