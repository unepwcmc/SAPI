Species.ElibrarySearchFormView = Ember.View.extend
  templateName: 'species/elibrary_search_form'
  classNames: ['search-block']

  actions:
    toggleSearchOptions: () ->
      @.$('.search-form').toggle()
      icon = @.$('.search-options-toggle > i')
      if icon.hasClass('fa-plus-circle')
        icon.addClass('fa-minus-circle').removeClass('fa-plus-circle')
      else
        icon.addClass('fa-plus-circle').removeClass('fa-minus-circle')
