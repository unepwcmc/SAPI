Species.TaxonConceptSearchResultView = Ember.View.extend
  tagName: 'h2'
  taxonConceptId: null
  taxonConcept: ( -> 
    Species.TaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')
  getQuery: ( ->
    @get('controller').get('controllers.search').get('taxonConceptQuery')
  ).property()
  template: ( ->
    Ember.Handlebars.compile(
      '{{#linkTo "taxon_concept.legal" view.taxonConcept}}
        {{#highlight view.taxonConcept.searchResultDisplay query=view.getQuery}}
          {{unbound this}}
        {{/highlight}}
      {{/linkTo}}
      ')
  ).property()
