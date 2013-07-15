Species.DownloadsButton = Ember.View.extend
  tagName: 'a'
  classNames: ['download']
  template: Ember.Handlebars.compile('DOWNLOAD SPECIES LISTS')
  didInsertElement: () ->
    if @get('controller.currentPath') == 'index'
      @.$().appendTo("#main")
