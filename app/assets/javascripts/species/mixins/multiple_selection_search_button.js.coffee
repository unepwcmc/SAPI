Species.MultipleSelectionSearchButton = Ember.Mixin.create
  tagName: 'a'
  href: '#'
  classNames: ['link']
  classNameBindings: ['loading']
  shortPlaceholder: true

  loading: ( ->
    "loading" unless @get('loaded')
  ).property('loaded').volatile()

  template: Ember.Handlebars.compile("{{view.summary}}"),
