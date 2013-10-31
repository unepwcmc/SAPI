Trade.ShipmentsController = Ember.ArrayController.extend
  needs: ['speciesListings', 'geoEntities']
  content: null
  currentShipment: null
  pages: null
  page: 1

  shipmentsSaving: ( ->
    @get('content').filterBy('isSaving', true).length > 0
  ).property('content.@each.isSaving')

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    @get('content').filterBy('isDirty', true).length
  ).property('content.@each.isDirty')

  setFilters: (filtersHash) ->
    @set('page', filtersHash.page)

  tableController: Ember.computed ->
    controller = Ember.get('Trade.ShipmentsTable.TableController').create()
    controller.set('shipmentsController', @)
    controller
  .property('content')

  allAppendixValues: ['I', 'II', 'III']
  allReporterTypeValues: ['E', 'I']

  setPages: ->
    total = @get('content.meta.total')
    if total
      pages = Math.ceil( total / @get('content.meta.per_page'))
      @set 'pages', pages
      return pages

  page: ( ->
    page = @get('content.meta.page') || 1
    if page
      @set('page', page)
      return page
  ).property('content.meta')

  showPrevPage: ( ->
    page = @get('page')
    if page > 1 then return yes else return no
  ).property('content.meta')

  showNextPage: ( ->
    page = @get('page')
    if page < @setPages() then return yes else return no
  ).property('content.meta')

  transitionToPage: (forward) ->
    if forward
      @set("page", parseInt(@page) + 1)
    else
      @set("page", parseInt(@page) - 1)
    @openShipmentsPage @page

  openShipmentsPage: (page) ->
    unless page then @set('page', 1)
    @transitionToRoute('shipments', {
      page: page or 1
    })

  actions:
    saveChanges: () ->
      @get('store').commit()

    cancelChanges: () ->
      @get('content').forEach (shipment) ->
        if (!shipment.get('isSaving'))
          shipment.get('transaction').rollback()
