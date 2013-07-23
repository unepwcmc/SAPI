Species.TaxonConceptsResultsCountView = Ember.View.extend
  templateName: 'species/taxon_concepts_results_count'

  didInsertElement: () ->
    $('.search-block').toggleClass('results')
