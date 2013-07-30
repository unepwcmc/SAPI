Species.GeoEntitiesSearchButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']
  classNameBindings: ['loading']

  loading: ( ->
    "loading" unless @get('loaded')
  ).property('loaded').volatile()

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    if (@get('selectedGeoEntities').length == 0)
      return "LOCATIONS"
    else if (@get('selectedGeoEntities').length == 1)
      return "1 LOC"
    else
      return @get('selectedGeoEntities').length + " LOCS"
  ).property("selectedGeoEntities.@each")
    