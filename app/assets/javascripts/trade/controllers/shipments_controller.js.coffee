Trade.ShipmentsController = Ember.ArrayController.extend
  content: null

  tableController: Ember.computed ->
    controller = Ember.get('Trade.ShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content')
    controller
  .property()
