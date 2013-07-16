Species.DownloadsButton = Ember.View.extend
  tagName: 'a'
  classNames: ['download']
  template: Ember.Handlebars.compile('DOWNLOAD SPECIES LISTS')
  click: (event) ->
    @set('controller.downloadsPopupVisible', true)
