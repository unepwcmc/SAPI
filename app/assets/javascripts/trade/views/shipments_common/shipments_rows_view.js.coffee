Trade.ShipmentsRowsView = Ember.CollectionView.extend
  tagName: 'tbody'
  content: null

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    templateName: 'trade/shipments_common/shipment_row'
    rowData: (->
      data = []
      @get('parentView.parentView.columns').forEach( (column) =>
        cellData = Ember.Object.create(
          value: @get('context').get(column.displayProperty)
        )
        if column.longDisplayProperty != undefined
          cellData.hasTooltip = false
          cellData.tooltip = @get('context').get(column.longDisplayProperty)
        data.push cellData
      )
      data
    ).property('context')
  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No shipments found")

  didInsertElement: ->
    $('.has-tooltip').tooltip()
