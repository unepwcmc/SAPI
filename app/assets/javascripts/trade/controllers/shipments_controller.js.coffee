Trade.ShipmentsController = Ember.ArrayController.extend
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  currentShipment: null

  shipmentsSaving: ( ->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    return false unless @get('content.isLoaded')
    @get('content').filterBy('isDirty', true).length
  ).property('content.@each.isDirty')

  tableController: Ember.computed ->
    controller = Ember.get('Trade.ShipmentsTable.TableController').create()
    controller.set('shipmentsController', @)
    controller
  .property('content')

  allAppendixValues: ['I', 'II', 'III']
  allReporterTypeValues: ['E', 'I']

  pages: ( ->
    total = @get('content.meta.total')
    if total
      return Math.ceil( total / @get('content.meta.per_page'))
    else
      return 1
  ).property('content.meta.total')

  page: ( ->
    @get('content.meta.page') || 1
  ).property('content.meta.page')

  showPrevPage: ( ->
    page = @get('page')
    if page > 1 then return yes else return no
  ).property('page')

  showNextPage: ( ->
    page = @get('page')
    if page < @get('pages') then return yes else return no
  ).property('page')

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@get('page')) + 1
    else
      parseInt(@get('page')) - 1
    @openShipmentsPage page

  openShipmentsPage: (page) ->
    @transitionToRoute('shipments', {queryParams:
      page: page or 1
    })

  actions:
    saveChanges: () ->
      # process deletes
      @get('content').filterBy('_destroyed', true).forEach (shipment) ->
        shipment.deleteRecord()
      # process updates
      @get('store').commit()
      @openShipmentsPage(@get('page'))

    cancelChanges: () ->
      @get('content').forEach (shipment) ->
        if (!shipment.get('isSaving'))
          shipment.get('transaction').rollback()
