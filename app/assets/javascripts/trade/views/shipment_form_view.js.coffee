Trade.ShipmentForm = Ember.View.extend
  classNames: ['modal hide fade shipment-form-modal']
  templateName: 'trade/shipment_form'
  content: null

  didInsertElement: ->
    @.$().on('hidden', () =>
      @set('controller.currentShipment', null)
    )

  # Selecting a value from `typeahead` will set the currentShipment value.
  # This re-sets both `typeahead` and currentShipment when deleting the value
  # from the text field.
  keyUp: (event) ->
    autocompleteTextInputs = ['term', 'unit']
    $element = $(event.target)
    if $element.val() == ''
      $element.typeahead 'setQuery', ''
      $.each autocompleteTextInputs, (index, input) =>
        if $element.hasClass(input)
          @set("controller.currentShipment.#{input}", '')
      
