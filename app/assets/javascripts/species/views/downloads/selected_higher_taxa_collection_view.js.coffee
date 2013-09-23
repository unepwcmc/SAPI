Species.SelectedHigherTaxaCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile(
      '{{fullName}} <span {{action "deleteTaxonConceptSelection" this}} class="delete">x</span>'
    )
