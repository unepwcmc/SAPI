Species.DownloadsButtonView = Ember.View.extend
  tagName: 'a'
  classNames: ['download']
  template: Ember.Handlebars.compile('DOWNLOAD SPECIES LISTS')
  templateName: 'species/downloads_button'
  click: (event) ->
    @set('controller.downloadsPopupVisible', true)
    @get('controller').send('ensureHigherTaxaLoaded')