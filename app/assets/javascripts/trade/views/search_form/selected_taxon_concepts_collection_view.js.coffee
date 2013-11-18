Trade.SelectedTaxonConceptsCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    template: Ember.Handlebars.compile(
      '{{this.fullName}} <a {{action "deleteSelection" this target="view.parentView"}} class="delete">x</a>'
    )

  actions:
    deleteSelection: (context) ->
      @get('content').removeObject(context)
