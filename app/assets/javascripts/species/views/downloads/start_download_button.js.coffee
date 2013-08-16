Species.StartDownloadButton = Ember.View.extend
  tagName: 'a'
  attributeBindings: ['href']

  href: '#'
  template: Ember.Handlebars.compile('DOWNLOAD')
  click: () ->
    @get('controller').send('startDownload')
