Species.ElibrarySearchFormView = Ember.View.extend
  templateName: 'species/elibrary_search_form'
  classNames: ['search-block']

  keyDown: (event) ->
    if event.keyCode == 13
      $('.elibrary-search-button').focus().trigger('click')

  actions:
    toggleSearchOptions: () ->
      @.$('.search-form').toggle()
      tag = @.$('.search-options-toggle')
      icon = tag.find('i')
      search_text = tag.find('.search-text')
      if icon.hasClass('fa-plus-circle')
        search_text.text('Hide search options')
      else if icon.hasClass('fa-minus-circle')
        search_text.text('Show search options')
      icon.toggleClass("fa-plus-circle fa-minus-circle")
