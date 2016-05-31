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
    if @get('controller.isSearchContextDocuments') &&
    @get('taxonConceptQuery') != @get('taxonConceptQueryLastCheck')
      @set('taxonConceptQueryLastCheck', @get('taxonConceptQuery'))
      if @get('taxonConceptQuery.length') >= 3
        query = @get('taxonConceptQuery')
      # we're in the E-Library search, need to check if
      # filtering by taxon is required for locations
      @get('controller.geoEntities').reload(query)
    @handlePopupClick(event)
