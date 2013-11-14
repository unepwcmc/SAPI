Trade.PermitSelection = Ember.View.extend
  tagName: 'li'

  template: ( ->
    Ember.Handlebars.compile(
      '<button {{ action "deletePermit" this  target="view"}}>X</button>{{this}}')
  ).property()

  actions:
    
    deletePermit: (property) ->
      @get('controller').selectedPermitProperties
        .removeObject property.toString()