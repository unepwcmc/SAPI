Species.TaxonConceptTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: () ->  
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')
    @showDropdown()

  focusOut: (event) ->
    if ($.browser.msie)
      if (@.$().val().length == 0)
        this.$().val(this.get('placeholder'))
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown()

  showDropdown: () ->
    if @.$().val().length > 2
      @set('controller.taxonConceptsDropdownVisible', true)   

  hideDropdown: () -> 
    @set('controller.taxonConceptsDropdownVisible', false)   

  keyUp: (event) ->
    @set('controller.taxonConceptQuery', event.currentTarget.value)
    @showDropdown()

  didInsertElement: () ->
    if ($.browser.msie)
      @.$().val(@.$().attr('placeholder'))
