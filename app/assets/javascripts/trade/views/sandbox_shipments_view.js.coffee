Trade.SandboxShipmentsView = Ember.CollectionView.extend
  tagName: 'tbody'
  content: null
  itemViewClass: Ember.View.extend
    templateName: 'trade/sandbox_shipment'
  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No results")
