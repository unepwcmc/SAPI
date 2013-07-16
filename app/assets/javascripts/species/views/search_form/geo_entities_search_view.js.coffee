Species.GeoEntitiesSearchView = Ember.View.extend
  classNames: ['location-area', 'popup-area']
  mousedOver: false

  mouseEnter: (event) ->
    @set('mousedOver', true)

  mouseLeave: (event) ->
    @set('mousedOver', false)