Species.DownloadsPopup = Ember.View.extend
  templateName: 'species/downloads_popup'
  classNames: ['download-block']

  didInsertElement: () ->
    $('input[name=csv_separator]').click( (e) ->
      $.cookie('speciesplus.csv_separator', e.target.value)
    )
