Trade.ShipmentTableView = Ember.View.extend
  tagName: 'tr'
  content: null

  layoutName: 'trade/editable-table/table_row'

  didInsertElement: ->
    #$('td > span.t, td i').tooltip()
