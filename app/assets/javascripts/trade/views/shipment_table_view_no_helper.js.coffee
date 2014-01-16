Trade.ShipmentTableViewNoHelper = Ember.View.extend
  tagName: 'tr'
  content: null
  classNameBindings: ['context._destroyed', 'context._modified']

  templateName: 'trade/editable-table/table_row_no_helper'

  didInsertElement: ->
    $('td > span.t, td i').tooltip()
    
