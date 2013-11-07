Trade.ShipmentForm = Ember.View.extend
  classNames: ['modal hide fade']
  templateName: 'trade/shipment_form'
  content: null

  didInsertElement: ->
    @.$().on('hidden', () =>
      console.log(@set('controller.currentShipment', null))
    )
