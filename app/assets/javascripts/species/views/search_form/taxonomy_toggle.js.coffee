Species.TaxonomyToggle = Ember.LinkView.extend
  href: '#'

  active: ( ->
    return @.get("option") == @.get("value")
  ).property('value')

  click: (e) ->
    @.set("value", @.get("option"))
