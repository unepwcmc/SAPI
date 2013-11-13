Trade.PermitAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  permitId: null

  autoCompletePermit: ( -> 
    Trade.AutoCompletePermit.find(@get('permitId'))
  ).property('permitId')

  template: ( ->
    Ember.Handlebars.compile(
      '
        {{#highlight view.autoCompletePermit.autoCompleteSuggestion query=controller.ShipmentsController}}
          {{unbound this}}
        {{/highlight}}
      ')
  ).property()

