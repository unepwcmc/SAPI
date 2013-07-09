Species.GeoEntitiesDropdown = Ember.View.extend
  classNames: ['location-area', 'popup-area']

  click: (e) ->

    $('#location-area-popup').toggle()
