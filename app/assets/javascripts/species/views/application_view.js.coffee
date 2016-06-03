Species.ApplicationView = Ember.View.extend
  templateName: 'species/application'
  didInsertElement: () ->
    $("button#remove").click ->
      $("div#banner").slideUp "normal"

  click: (event) ->
    $('.popup-clickable').hide() unless $(event.target).closest('.search-block01').length
