Species.SortableColumnComponent = Ember.Component.extend
  layoutName: 'species/components/sortable-column'
  tagName: 'th'
  classNameBindings: ['order']
  order: 'desc'

  click: () ->
    column = this.get('classNames')[1]
    if column == 'event-date-col'
      sortCol = 'date_raw'
    else if column == 'event-col'
      sortCol = 'event_name'
    else
      sortCol = 'title'
    order = @get('order')
    if order == 'asc'
      sortDir = 'desc'
    else
      sortDir = 'asc'
    @set('order', sortDir)
    @sendAction('action', @get('eventType'), sortCol, sortDir)
