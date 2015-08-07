Species.TaxonConceptAutoCompleteLookup = Ember.Mixin.create({

  taxonConceptQuery: null
  taxonConceptQueryForDisplay: null

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')
    if not taxonConceptQuery or taxonConceptQuery.length < 3
      return;
    Species.AutoCompleteTaxonConcept.find(
      taxonomy: @get('taxonomy')
      taxon_concept_query: taxonConceptQuery
    )
  ).property('taxonConceptQuery')

  taxonConceptQueryRe: ( ->
    new RegExp("^"+@get('taxonConceptQuery'),"i")
  ).property('taxonConceptQuery')

})
