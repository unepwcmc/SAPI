Species.AutoCompleteTaxonConceptView = Ember.View.extend
  tagName: 'li'
  taxonConceptId: null
  taxonConcept: ( -> 
    Species.TaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')
  template: Ember.Handlebars.compile('<a href="#">{{highlight view.taxonConcept.autoCompleteSuggestion controller.taxonConceptQuery}}</a>')
  click: (e) ->
    console.log('click')