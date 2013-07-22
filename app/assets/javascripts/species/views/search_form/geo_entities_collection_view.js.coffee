Species.GeoEntitiesCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null

  geoEntityType: null

  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No matches")

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    template: Ember.Handlebars.compile("{{{name}}}")

    click: (event) ->
      @get('controller.selectedGeoEntities').addObject(@get('context'))

