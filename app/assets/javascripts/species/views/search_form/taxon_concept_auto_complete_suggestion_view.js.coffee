Species.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  taxonConceptId: null

  autoCompleteTaxonConcept: ( -> 
    Species.AutoCompleteTaxonConcept.find(@get('taxonConceptId'))
  ).property('taxonConceptId')

  template: ( ->
    rankName = @get('autoCompleteTaxonConcept.rankName')
    if rankName == 'SPECIES' or rankName == 'SUBSPECIES'
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

