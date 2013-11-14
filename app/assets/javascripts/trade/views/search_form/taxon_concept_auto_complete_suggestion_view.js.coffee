Trade.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  content: null
  contextBinding: 'content'
  selectedValues: null

  template: ( ->
    Ember.Handlebars.compile(
      '{{#highlight view.content.autoCompleteSuggestion query=view.query}}
        {{unbound view.content}}
      {{/highlight}}'
    )
  ).property()

  click: (event) ->
    @get('selectedValues').addObject(@get('context'))
