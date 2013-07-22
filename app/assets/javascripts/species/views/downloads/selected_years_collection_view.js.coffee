Species.SelectedYearsCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile('{{this}} <span {{action "deleteSelection" target="view"}} class="delete">x</span>')

    deleteSelection: (event) ->
      @set('controller.selectedYears', [])

