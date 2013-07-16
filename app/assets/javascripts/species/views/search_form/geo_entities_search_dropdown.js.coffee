Species.GeoEntitiesSearchDropdown = Ember.View.extend
  templateName: 'species/geo_entities_search_dropdown'
  classNames: ['popup-holder01']
  init: () ->
    @.set('elementId', 'location-area-popup')
    return @._super()
