Species.HigherTaxaCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null

  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No matches")

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    template: Ember.Handlebars.compile("{{unbound fullName}}")

    click: (event) ->
      @set('controller.selectedTaxonConcepts', [@get('context')])

