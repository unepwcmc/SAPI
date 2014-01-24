Species.TaxonConceptSearchTextField = Em.TextField.extend
  value: ''
  currentTimeout: null

  attributeBindings: ['autocomplete']

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    Ember.run.cancel(@currentTimeout)
    @currentTimeout = Ember.run.later(@, ->
      @showDropdown()
      @set('query', event.target.value)
    , 1000)

  hideDropdown: () ->
    $('.search fieldset').removeClass('parent-focus parent-active')

  showDropdown: () ->
    if @.$().val().length > 2
      $('.search fieldset').addClass('parent-focus parent-active')
