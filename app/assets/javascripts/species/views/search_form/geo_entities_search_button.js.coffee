Species.GeoEntitiesSearchButton = Ember.View.extend Species.MultipleSelectionSearchButton, Species.SearchFormDropdowns,

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

  click: (event) ->
    @_super(event, 'controller.geoEntities')
