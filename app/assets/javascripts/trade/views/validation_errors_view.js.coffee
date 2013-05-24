Trade.ValidationErrorsView = Ember.CollectionView.extend
  tagName: 'tbody'
  content: null
  itemViewClass: Ember.View.extend
    templateName: 'trade/validation_error'
  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No results")
