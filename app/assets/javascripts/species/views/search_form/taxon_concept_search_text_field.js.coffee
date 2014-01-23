Species.TaxonConceptSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  focusOut: (event) ->
    @set('queryActive', false)
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    if @get('queryActive') is false
      @set('queryActive', true)
    else
      @showDropdown()
    @set('query', event.currentTarget.value)

  hideDropdown: () -> 
    $('.search fieldset').removeClass('parent-focus parent-active')

  showDropdown: () ->
    if @.$().val().length > 2
      $('.search fieldset').addClass('parent-focus parent-active') 
