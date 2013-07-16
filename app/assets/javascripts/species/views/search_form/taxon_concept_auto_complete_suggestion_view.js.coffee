Species.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  taxonConceptId: null
  taxonConcept: ( -> 
    Species.TaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')
  template: ( ->
    if @get('taxonConcept.rankName') == 'SPECIES'
      Ember.Handlebars.compile('{{#linkTo "taxon_concept.legal" view.taxonConcept}}{{highlight view.taxonConcept.autoCompleteSuggestion controller.taxonConceptQuery}}{{/linkTo}}')
    else
      Ember.Handlebars.compile('<a href="#">{{highlight view.taxonConcept.autoCompleteSuggestion controller.taxonConceptQuery}}</a>')
  ).property()
