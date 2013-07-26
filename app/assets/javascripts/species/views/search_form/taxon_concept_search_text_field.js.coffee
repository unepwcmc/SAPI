Species.TaxonConceptSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: (event) ->  
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')
    @showDropdown()

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    @set('value', event.currentTarget.value)
    @showDropdown()

  hideDropdown: () -> 
    @set('dropdownIsVisible', false)   

  showDropdown: () ->
    if @.$().val().length > 2
      @set('dropdownIsVisible', true)   
