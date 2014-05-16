Species.TaxonConceptsController = Ember.ArrayController.extend Species.Spinner, Species.TaxonConceptPagination,
  needs: ['search', 'taxonConceptLink']

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
