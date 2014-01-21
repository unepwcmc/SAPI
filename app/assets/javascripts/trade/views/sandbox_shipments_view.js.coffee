Trade.SandboxShipmentsView = Ember.View.extend
  templateName: 'trade/sandbox_shipments'

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no