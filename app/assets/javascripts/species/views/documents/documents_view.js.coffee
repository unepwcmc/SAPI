Species.DocumentsView = Ember.View.extend
  templateName: 'species/documents'

  didInsertElement: () ->
    $('body').addClass('inner')
    $(".search-block").addClass("search-results")
