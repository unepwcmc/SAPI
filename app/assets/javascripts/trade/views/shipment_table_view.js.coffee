Trade.ShipmentTableView = Ember.View.extend
  tagName: 'tr'
  content: null
  
  templateName: 'trade/editable-table/table_row'

  didInsertElement: ->
    $('td > span.t, td i').tooltip()
    
