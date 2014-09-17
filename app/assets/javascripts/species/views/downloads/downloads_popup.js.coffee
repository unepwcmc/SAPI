Species.DownloadsPopup = Ember.View.extend
  templateName: 'species/downloads_popup'
  classNames: ['dwonload-block']

  didInsertElement: () ->
    $('input[name=csv_separator]').click( (e) ->
      $.cookie('speciesplus.csv_separator', e.target.value)
    )

  actions:

    showHideCsvOptions: () ->
      csvOptions = $('.csv_options')
      if $('#csv_options').is(':visible')
        $('#csv_options').hide()
      else
        $('#csv_options').show()
