Species.EventLookup = Ember.Mixin.create
  selectedEvent: null
  selectedEventId: null

  initEventSelector: ->
    @set('selectedEvent', @get('controllers.events.content').findBy('id', @get('selectedEventId')))
    if @get('selectedEventType') == null && @get('selectedEvent')
      @set('selectedEventType', @get('controllers.events.eventTypes').findBy('id', @get('selectedEvent.type')))

  filteredEvents: ( ->
    if @get('selectedEventType')
      @get('controllers.events.content').filterBy('type', @get('selectedEventType.id'))
    else
      []
  ).property('selectedEventType.id')

  eventsDropdownVisible: ( ->
    @get('selectedEventType')?
  ).property('selectedEventType.id')

  actions:
    handleEventTypeSelection: (eventType) ->
      @set('selectedEventType', eventType)
      if @get('selectedEventType.id') != @get('selectedEvent.type')
        @set('selectedEvent', null)
        @set('selectedEventId', null)
      if @get('selectedDocumentType.eventTypes') && @get('selectedDocumentType.eventTypes').indexOf(@get('selectedEvent.type')) < 0
        @set('selectedDocumentType', null)

    handleEventTypeDeselection: (eventType) ->
      @set('selectedEventType', null)
      @set('selectedEvent', null)
      @set('selectedEventId', null)

    handleEventSelection: (event) ->
      @set('selectedEvent', event)
      @set('selectedEventId', event.id)

    handleEventDeselection: (event) ->
      @set('selectedEvent', null)
      @set('selectedEventId', null)
