Species.TaxonConceptDocumentsController = Ember.ArrayController.extend
  needs: 'taxonConcept'
  ecSrgDocsIsLoading: true
  citesCopDocsIsLoading: true
  citesAcDocsIsLoading: true
  citesPcDocsIsLoading: true
  otherDocsIsLoading: true

  ecSrgDocsObserver: ( ->
    console.log("hello ec srg")
    @set('ecSrgDocsIsLoading', false)
  ).observes('controllers.taxonConcept.ec_srg_docs.@each.didLoad')

  citesCopDocsObserver: ( ->
    @set('citesCopDocsIsLoading', false)
  ).observes('controllers.taxonConcept.cites_cop_docs.@each.didLoad')

  citesAcDocsObserver: ( ->
    @set('citesAcDocsIsLoading', false)
  ).observes('controllers.taxonConcept.cites_ac_docs.@each.didLoad')

  citesPcDocsObserver: ( ->
    @set('citesPcDocsIsLoading', false)
  ).observes('controllers.taxonConcept.cites_pc_docs.@each.didLoad')

  citesOtherDocsObserver: ( ->
    @set('citesOtherDocsIsLoading', false)
  ).observes('controllers.taxonConcept.cites_other_docs.@each.didLoad')
