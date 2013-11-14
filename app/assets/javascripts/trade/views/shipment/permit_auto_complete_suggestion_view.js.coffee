Trade.PermitAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  permit: null

  template: ( ->
    Ember.Handlebars.compile(
      '<a href="#" {{action storePermit target="view"}}>
        {{#highlight view.permit.number query=controller.permitQuery}}
          {{unbound this}}
        {{/highlight}}
      </a>')
  ).property()

  actions:

    storePermit: ->
      @get('controller').selectedPermitProperties
        .addObject @.get("permit.number")


