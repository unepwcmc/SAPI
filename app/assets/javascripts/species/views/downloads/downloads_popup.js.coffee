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
      csvOptionsLink = $('.csv_options_holder > a')
      if $('#csv_options').is(':visible')
        $('#csv_options').hide()
        csvOptionsLink.html('Trouble viewing outputs?')
      else
        $('#csv_options').show()
        csvOptionsLink.html('Try changing the option below for .csv outputs:')

