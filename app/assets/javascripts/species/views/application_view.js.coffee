Species.ApplicationView = Ember.View.extend
  templateName: 'species/application'
  didInsertElement: () ->
    $("button#remove").click ->
      $("div#banner").slideUp "normal"
