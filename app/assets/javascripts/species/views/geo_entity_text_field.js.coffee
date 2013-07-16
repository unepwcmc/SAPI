Species.GeoEntityTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: () ->
    if (@.$().val() == @get('placeholder'))
      @.$().val('')

    @.$().attr('placeholder', '')

  focusOut: (event) ->
    if ($.browser.msie)
      if (@.$().val().length == 0)
        this.$().val(this.get('placeholder'))
    @.$().attr('placeholder', @get('placeholder'))

  keyUp: (event) ->
    @set('controller.geoEntityQuery', event.currentTarget.value)

