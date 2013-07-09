Species.SelectedGeoEntitiesCollectionView = Ember.CollectionView.extend
  tagName: 'ul',
  content: null,

  geoEntityType: null,

  itemViewClass: Ember.View.extend
    contextBinding: 'content',
    template: Ember.Handlebars.compile('{{name}} <span {{action "deleteSelection" target="view"}} class="delete">x</span>')

    deleteSelection: (event) ->
      @get('controller.selectedGeoEntities').removeObject(@get('context'))

