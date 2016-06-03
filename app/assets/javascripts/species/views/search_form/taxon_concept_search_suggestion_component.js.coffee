Species.TaxonConceptSearchSuggestionComponent = Ember.Component.extend({
  layoutName: 'species/components/taxon-concept-search-suggestion'
  tagName: 'li'
  targetObject: Em.computed.alias('parentView')
  autoCompleteTaxonConcept: ( ->
    Species.AutoCompleteTaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')

  click: () ->
    @sendAction('action', @get('autoCompleteTaxonConcept'))
    false # don't bubble
});
