Species.GeoEntitiesSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: (event) ->  
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    @set('controller.geoEntityQuery', event.currentTarget.value)

  hideDropdown: () -> 
    @set('controller.geoEntitiesDropdownVisible', false)   
