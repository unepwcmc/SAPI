Species.GeoEntitiesSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: (event) ->
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))

  keyUp: (event) ->
    @set('controller.geoEntityQuery', event.currentTarget.value)
