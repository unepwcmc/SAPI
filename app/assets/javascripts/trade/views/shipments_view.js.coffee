Trade.ShipmentsView = Ember.View.extend
  layoutName: 'trade/shipments'

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no
