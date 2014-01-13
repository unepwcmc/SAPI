Trade.SandboxShipmentTableView = Ember.View.extend
  tagName: 'tr'
  content: null
  
  templateName: 'trade/editable-table/sandbox_table_row'

  didInsertElement: ->
    $('td > span.t, td i').tooltip()