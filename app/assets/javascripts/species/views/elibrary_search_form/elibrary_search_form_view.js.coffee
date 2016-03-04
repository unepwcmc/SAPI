Species.ElibrarySearchFormView = Ember.View.extend
  templateName: 'species/elibrary_search_form'
  classNames: ['search-block']

  keyDown: (event) ->
    if event.keyCode == 13
      $('.elibrary-search-button').click()

  actions:
    toggleSearchOptions: () ->
      @.$('.search-form').toggle()
      icon = @.$('.search-options-toggle > i')
      icon.toggleClass("fa-plus-circle fa-minus-circle")
