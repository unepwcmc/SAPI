Species.TaxonConceptAutoCompleteSuggestionComponent = Ember.Component.extend({
  layoutName: 'species/components/taxon-concept-auto-complete-suggestion'
  tagName: 'li'
  autoCompleteTaxonConcept: ( ->
    Species.AutoCompleteTaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')

  click: () ->
    @sendAction('action', @get('autoCompleteTaxonConcept'))
    false # don't bubble
});
