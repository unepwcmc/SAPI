Species.GeoEntitiesSearchButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']
  classNameBindings: ['loading']
  shortPlaceholder: true

  loading: ( ->
    "loading" unless @get('loaded')
  ).property('loaded').volatile()

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    short = (@get('shortPlaceholder') == true)
    if (@get('selectedGeoEntities').length == 0)
      if short
        "LOCATIONS"
      else
        "All locations"
    else if (@get('selectedGeoEntities').length == 1)
      if short
        "1 LOC"
      else
       "1 location"
    else
      if short
        @get('selectedGeoEntities').length + " LOCS"
      else
        @get('selectedGeoEntities').length + " locations"
  ).property("selectedGeoEntities.@each")
    