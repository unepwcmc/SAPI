Species.DownloadsButtonView = Ember.View.extend Species.Spinner,
  tagName: 'a'
  classNames: ['download']
  template: Ember.Handlebars.compile('DOWNLOAD SPECIES LISTS')
  templateName: 'species/downloads_button'
  click: (event) ->
    @set('controller.downloadsPopupVisible', true)
    # Using the spinner cover here, without the spinner!
    $(@spinnerSelector).css("visibility", "visible").find('img').hide()
    @get('controller').send('ensureHigherTaxaLoaded')
