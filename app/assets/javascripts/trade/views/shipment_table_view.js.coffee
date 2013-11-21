Trade.ShipmentTableView = Ember.View.extend
  tagName: 'tr'
  content: null

  templateName: 'trade/editable-table/table_row'

  click: (event) ->
    content = @get('content')
    @get('controller').set('currentShipment', content)
    action = event.originalEvent.srcElement?.name
    if action == 'delete'
      this.get('controller').send('deleteShipment')
    else if action == 'edit'
      this.get('controller').send('editShipment')
    
