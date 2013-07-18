Species.StartDownloadButton = Ember.View.extend
  tagName: 'a'
  attributeBindings: ['href']
  href: ( ->
  	@get('controller.downloadUrl')
  ).property('controller.downloadUrl')
  template: Ember.Handlebars.compile('DOWNLOAD')
