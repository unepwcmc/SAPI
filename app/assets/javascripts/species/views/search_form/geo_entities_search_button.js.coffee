Species.GeoEntitiesSearchButton = Ember.View.extend
  tagName: 'a'
  template: Ember.Handlebars.compile('Locations')

  click: (event) ->
    @set('controller.geoEntitiesDropdownVisible', true)