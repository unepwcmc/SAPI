Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner, Species.TaxonConceptPagination,
  needs: ['search', 'taxonConceptLink']
  content: null

  contentObserver: ( ->
    meta = @get('content.meta')
    if meta != undefined &&  meta.total == 1
      @openTaxonPage(meta.higher_taxa_headers[0].taxon_concept_ids[0], false)
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
    @transitionToRoute('taxonConcept.legal', m, {queryParams:
      {
        taxon_concept_query: false,
        geo_entities_ids: false,
        geo_entity_scope: false,
        page: false
      }
    })

  actions:
    openTaxonPage: (taxonConceptId, redirected) ->
      @openTaxonPage(taxonConceptId, redirected)

    nextPage: ->
      @get("controllers.search").openSearchPage undefined, @get('page') + 1, @get('perPage')

    prevPage: ->
      @get("controllers.search").openSearchPage undefined, @get('page') - 1, @get('perPage')
