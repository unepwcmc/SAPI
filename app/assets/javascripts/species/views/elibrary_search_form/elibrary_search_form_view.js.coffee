Species.ElibrarySearchFormView = Ember.View.extend
  templateName: 'species/elibrary_search_form'
  classNames: ['search-block']

  actions:
    toggleSearchOptions: () ->
      @.$('.search-form').toggle()
      icon = @.$('.search-options-toggle > i')
      icon.toggleClass("fa-plus-circle fa-minus-circle")
