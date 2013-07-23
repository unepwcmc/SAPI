Species.TaxonConceptSearchResultView = Ember.View.extend
  tagName: 'h2'
  taxonConceptId: null
  taxonConcept: ( -> 
    Species.TaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')
  template: ( ->
    Ember.Handlebars.compile('{{#linkTo "taxon_concept.legal" view.taxonConcept}}{{view.taxonConcept.fullName}} <span>{{view.taxonConcept.authorYear}}</span>{{/linkTo}}')
  ).property()
