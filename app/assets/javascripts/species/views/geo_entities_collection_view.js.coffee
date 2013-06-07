Species.GeoEntitiesCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null
  searchController: null

  geoEntityType: null

  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No matches")

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    template: Ember.Handlebars.compile("{{{name}}}")

    click: (event) ->
      @set('controller.geoEntityId', @get('context.id'))
