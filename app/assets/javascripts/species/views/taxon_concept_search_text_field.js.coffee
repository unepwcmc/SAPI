Species.TaxonConceptSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: (event) ->  
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')
    @showDropdown()

  focusOut: (event) ->
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    @set('controller.taxonConceptQuery', event.currentTarget.value)
    @showDropdown()

  hideDropdown: () -> 
    @set('controller.taxonConceptsDropdownVisible', false)   

  showDropdown: () ->
    if @.$().val().length > 2
      @set('controller.taxonConceptsDropdownVisible', true)   



