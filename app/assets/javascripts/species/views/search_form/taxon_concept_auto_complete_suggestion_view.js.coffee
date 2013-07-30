Species.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  taxonConceptId: null

  autoCompleteTaxonConcept: ( -> 
    Species.AutoCompleteTaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')

  template: ( ->
    if @get('autoCompleteTaxonConcept.rankName') == 'SPECIES'
      Ember.Handlebars.compile(
        '<a href="#" {{action openTaxonPage view.taxonConceptId}}>
          {{#highlight view.autoCompleteTaxonConcept.autoCompleteSuggestion query=controller.taxonConceptQuery}}
            {{unbound this}}
          {{/highlight}}
        </a>')
    else
      Ember.Handlebars.compile(
        '<a href="#" {{action openSearchPage view.autoCompleteTaxonConcept.fullName}}>
          {{#highlight view.autoCompleteTaxonConcept.autoCompleteSuggestion query=controller.taxonConceptQuery}}
            {{unbound this}}
          {{/highlight}}
        </a>')
  ).property()

