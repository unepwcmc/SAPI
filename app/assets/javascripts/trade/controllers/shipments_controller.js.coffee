Trade.ShipmentsController = Ember.ArrayController.extend
  content: null

  tableController: Ember.computed ->
    controller = Ember.get('Trade.ShipmentsTable.TableController').create()
    controller.set 'shipments', @get('content')
    controller
  .property('content')

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
