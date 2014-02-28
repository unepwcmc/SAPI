Species.TaxonConceptSearchTextField = Em.TextField.extend
  value: ''
  currentTimeout: null

  attributeBindings: ['autocomplete']

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    Ember.run.cancel(@currentTimeout)
    if event.keyCode == 13
      @hideDropdown()
      return
    @currentTimeout = Ember.run.later(@, ->
      @showDropdown()
      @set('query', event.target.value)
    , 500)

  hideDropdown: () ->
    $('.search fieldset').removeClass('parent-focus parent-active')

  showDropdown: () ->
    if @.$().val().length > 2
      $('.search fieldset').addClass('parent-focus parent-active')
