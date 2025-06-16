Species.TaxonConceptAutoCompleteLookup = Ember.Mixin.create({

  taxonConceptQuery: null
  taxonConceptQueryForDisplay: null

  autoCompleteTaxonConcepts: ( ->
    taxonConceptQuery = @get('taxonConceptQuery')

    # No lower limit on some non-latin characters
    if not taxonConceptQuery or (
      taxonConceptQuery.length < 3 and
      not /[^\x00-\u0530]/.test(taxonConceptQuery)
    )
      return;

    ac_params = {
      taxonomy: @get('taxonomy')
      taxon_concept_query: taxonConceptQuery
    }

    ac_params['visibility'] = 'elibrary' if @get('searchContext') == 'documents'

    Species.AutoCompleteTaxonConcept.find(ac_params)
  ).property('taxonConceptQuery')

  taxonConceptQueryRe: ( ->
    new RegExp("^"+@get('taxonConceptQuery'),"i")
  ).property('taxonConceptQuery')

})
