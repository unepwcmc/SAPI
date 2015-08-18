Species.SortableColumnComponent = Ember.Component.extend
  layoutName: 'species/components/sortable-column'
  tagName: 'th'
  classNameBindings: ['order']
  order: ''

  click: (event) ->
    @toggleOrder()
    component = this
    th = $(event.target).closest('th')
    column = this.get('classNames')[1]
    tbody = $(th).closest('.inner-table-container').find('.table-body tbody')
    $(tbody).find('tr').sort( (a, b) ->
      tda = $(a).find('td.'+column).text().toLowerCase()
      tdb = $(b).find('td.'+column).text().toLowerCase()
      if column == 'event-date-col'
        return component.sortDate(tda, tdb, component.get('order'))
      else
        return component.sortAlphaNum(tda, tdb, component.get('order'))
    ).appendTo($(tbody))

  sortDate: (a, b, order) ->
    aparts = a.split('/')
    bparts = b.split('/')
    da = new Date(parseInt(aparts[2], 10),
                  parseInt(aparts[1], 10) - 1,
                  parseInt(aparts[0], 10))
    db = new Date(parseInt(bparts[2], 10),
                  parseInt(bparts[1], 10) - 1,
                  parseInt(bparts[0], 10))
                  
    return 0 if da == db
    if order == 'asc'
      return 1 if da > db
      return -1 if da < db
    else
      return 1 if da < db
      return -1 if da > db

  sortAlphaNum: (a, b, order) ->
    reA = /[^a-zA-Z]/g
    reN = /[^0-9]/g
    aA = a.replace(reA, "")
    bA = b.replace(reA, "")
    if aA.localeCompare(bA) == 0
      aN = parseInt(a.replace(reN, ""), 10)
      bN = parseInt(b.replace(reN, ""), 10)
      if order == 'asc'
        return aN-bN
      else
        return bN-aN
    else
      if order == 'asc'
        aA.localeCompare(bA)
      else
        bA.localeCompare(aA)

  toggleOrder: ->
    order = this.get('order')
    if order == '' or order =='desc'
      order = 'asc'
    else
      order = 'desc'
    this.set('order', order)
