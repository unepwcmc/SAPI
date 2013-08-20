Species.ToggleButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNameBindings: ['active:active:']

  active: ( ->
    return @.get("option") == @.get("value")
  ).property('value')

  click: (e) ->
    option = @.get("option")
    @.set("value", option)
    @get('controller').send('redirectToOpenSearchPage', option)