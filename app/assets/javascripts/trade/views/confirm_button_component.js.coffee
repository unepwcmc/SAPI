Trade.ConfirmButtonComponent = Ember.Component.extend
  templateName: 'trade/components/confirm-button'
  actions:
    showConfirmation: () ->
      if confirm("Secondary errors detected. Save anyway?")
        @sendAction('action', @get('shipment'), true)

    confirm: () ->
      @sendAction('action', @get('shipment'), false)