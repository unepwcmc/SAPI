Species.StartDownloadButton = Ember.View.extend
  tagName: 'a'
  attributeBindings: ['href']

  href: '#'
  template: Ember.Handlebars.compile('DOWNLOAD')
  click: (event) ->
    event.preventDefault()
    @get('controller').send('startDownload')
