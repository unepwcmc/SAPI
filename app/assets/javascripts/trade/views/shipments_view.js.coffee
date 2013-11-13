Trade.ShipmentsView = Ember.View.extend
  templateName: 'trade/shipments'

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no

    testQueryParams: ->
      @controller.testQueryParams
