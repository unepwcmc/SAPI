Trade.ShipmentForm = Ember.View.extend
  classNames: ['modal hide fade shipment-form-modal']
  templateName: 'trade/shipment_form'
  content: null

  didInsertElement: ->
    @.$().on('hidden', () =>
      @set('controller.currentShipment', null)
    )
      
