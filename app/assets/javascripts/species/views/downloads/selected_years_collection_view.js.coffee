Species.SelectedYearsCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile(
      '{{this}} <span {{action "deleteYearSelection" this}} class="delete">x</span>'
    )
