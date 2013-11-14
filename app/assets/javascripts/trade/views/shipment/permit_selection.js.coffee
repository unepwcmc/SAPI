Trade.PermitSelection = Ember.View.extend
  tagName: 'li'

  template: ( ->
    Ember.Handlebars.compile(
      '<span class"selection">{{this}}</span><button {{ action "deletePermit" this  target="view"}}>X</button>')
  ).property()

  actions:
    
    deletePermit: (property) ->
      @get('controller').selectedPermitProperties
        .removeObject property.toString()