Trade.ShipmentForm = Ember.View.extend
  classNames: ['modal hide fade shipment-form-modal']
  layoutName: 'trade/search/shipment_form'
  content: null

  didInsertElement: ->
    @.$().on('hidden', () =>
      @get('controller').send('cancelShipment')
    )
      
