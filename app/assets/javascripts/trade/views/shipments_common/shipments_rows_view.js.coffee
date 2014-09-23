Trade.ShipmentsRowsView = Ember.CollectionView.extend
  tagName: 'tbody'
  content: null

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    templateName: 'trade/shipments_common/shipment_row'

  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No shipments found")
