Species.TaxonConceptSearchFieldComponent = Em.TextField.extend
  currentTimeout: null

  attributeBindings: ['autocomplete']

  targetObject: Em.computed.alias('parentView')

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @get('targetObject').hideDropdown() if !@get('targetObject.mousedOver')

  keyUp: (event) ->
    Ember.run.cancel(@currentTimeout)
    if event.keyCode == 13
      @get('targetObject').hideDropdown()
      return
    @currentTimeout = Ember.run.later(@, ->
      if @.$()?.val().length > 2
        @get('targetObject').showDropdown()
      else
        @get('targetObject').hideDropdown()
      @set('query', event.target.value)
    , 500)
