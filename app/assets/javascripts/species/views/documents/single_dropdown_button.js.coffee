Species.SingleDropdownButton = Ember.View.extend(Species.SearchFormDropdowns,
  tagName: 'a'
  classNames: ['link']

  template: Ember.Handlebars.compile("{{view.placeholder}}"),

  placeholder: ->
    @get('placeholder')
)
