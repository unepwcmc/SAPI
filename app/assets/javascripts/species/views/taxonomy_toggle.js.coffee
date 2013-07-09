Species.TaxonomyToggle = Ember.View.extend
  template: Ember.Handlebars.compile("<a href=\"#\">{{view.label}}</a>")
  classNameBindings: ['active'],
  # If the value of a class name binding returns a boolean the property name
  # itself will be used as the class name if the property is true. The class
  # name will not be added if the value is false or undefined.
  active: ( ->
    console.log(@.get("option") )
    console.log(@.get("value") )
    return @.get("option") == @.get("value")
  ).property()
  # active: (->
  #   @.get("option") == @.get("value")
  # ).property()

  click: (e) ->
    console.log(e)
    @.set("value", @.get("option"))

