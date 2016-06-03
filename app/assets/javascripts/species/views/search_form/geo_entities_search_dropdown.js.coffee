Species.GeoEntitiesSearchDropdown = Ember.View.extend
  templateName: 'species/geo_entities_search_dropdown'
  classNames: ['popup-clickable', 'popup-holder01']
  placeholder: ( ->
    if @get('controller.isSearchContextDocuments')
      'Type to filter countries or territories'
    else
      'Type to filter countries or regions'
  ).property('controller.isSearchContextDocuments')
