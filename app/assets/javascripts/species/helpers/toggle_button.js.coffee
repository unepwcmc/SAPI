Species.ToggleButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNameBindings: ['active:active:']

  active: ( ->
    return @.get("option") == @.get("value")
  ).property('value')

  click: (e) ->
    @.set("value", @.get("option"))
