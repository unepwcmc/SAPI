Species.SearchTaxonomyToggleButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNameBindings: ['active:active:']

  active: ( ->
    @get("option") == @get("value")
  ).property('value')

  click: (e) ->
    option = @.get("option")
    @set("value", option)
    @get('controller').send('redirectToOpenSearchPage', {"taxonomy": option})
