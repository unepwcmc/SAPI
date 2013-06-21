Species.SelectedGeoEntitiesCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  geoEntityType: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile('{{name}} <a href="#" {{action "deleteSelection" target="view"}} class="delete">x</a>')

    deleteSelection: (event) ->
      @get('controller.selectedGeoEntities').removeObject(@get('context'))

