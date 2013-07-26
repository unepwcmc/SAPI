Species.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  taxonConceptId: null
  taxonConcept: ( -> 
    Species.TaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')
  setSearchParams: ( ->
    {
      taxonomy: @get('controller').get('taxonomy'),
      taxon_concept_query: @get('controller').get('taxonConceptQuery')
    }
  ).property('taxonConceptQuery')
  template: ( ->
    if @get('taxonConcept.rankName') == 'SPECIES'
      Ember.Handlebars.compile(
        '{{#linkTo "taxon_concept.legal" view.taxonConcept}}
          {{#highlight view.taxonConcept.autoCompleteSuggestion query=controller.taxonConceptQuery}}
            {{unbound this}}
          {{/highlight}}
        {{/linkTo}}')
    else
      Ember.Handlebars.compile('
        {{#linkTo "search" view.setSearchParams }}
          {{#highlight view.taxonConcept.autoCompleteSuggestion query=controller.taxonConceptQuery}}
            {{unbound this}}
          {{/highlight}}
        {{/linkTo}}
        ')
  ).property()
