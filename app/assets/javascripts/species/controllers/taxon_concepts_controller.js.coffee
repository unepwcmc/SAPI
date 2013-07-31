Species.TaxonConceptsController = Ember.ArrayController.extend
  needs: 'search'
  content: null

  contentObserver: ( ->
    if @get('content').meta != undefined &&  @get('content').meta.total == 1
      @get('controllers.search').set('redirected', true)
      @openTaxonPage(@get('content').meta.higher_taxa_headers[0].taxon_concept_ids[0])
  ).observes("content.meta.didLoad")

  openTaxonPage: (taxonConceptId) ->
    m = Species.TaxonConcept.find(taxonConceptId)
    if m.get('mTaxonConcept') == undefined
      m.reload()
    @transitionToRoute('taxon_concept.legal', m)
