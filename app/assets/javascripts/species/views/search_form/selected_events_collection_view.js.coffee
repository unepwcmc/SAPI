Species.SelectedEventsCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  geoEntityType: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile(
      '{{name}} <span {{action "deleteEventSelection" this}} class="delete">x</span>'
    )
