Species.DownloadsPopup = Ember.View.extend
  templateName: 'species/downloads_popup'
  classNames: ['dwonload-block']

  actions:

    showHideCsvOptions: () ->
      csvOptions = $('.csv_options')
      if $('#csv_options').is(':visible')
        $('#csv_options').hide()
      else
        $('#csv_options').show()
