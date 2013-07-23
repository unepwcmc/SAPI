Species.GeoEntitiesSearchButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']

  controller: null

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedGeoEntities = @get('controller.selectedGeoEntities')
    if (selectedGeoEntities.length == 0)
      return "LOCATIONS"
    else if (selectedGeoEntities.length == 1)
      return "1 LOC"
    else
      return selectedGeoEntities.length + " LOCS"
  ).property("controller.selectedGeoEntities.@each")
