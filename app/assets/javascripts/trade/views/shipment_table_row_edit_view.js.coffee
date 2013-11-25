Trade.ShipmentTableRowEdit = Ember.View.extend
  classNames: ['edit_row']
  tagName: 'div'
  content: null

  template: Ember.Handlebars.compile(
    "<button {{action 'cancelShipment'}}>Delete</button><button  {{action 'editShipment'}}>Edit</button>"
  )