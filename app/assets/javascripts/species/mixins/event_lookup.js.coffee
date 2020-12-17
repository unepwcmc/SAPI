Species.EventLookup = Ember.Mixin.create
  selectedEvents: []
  selectedEventsIds: []

  filteredEvents: ( ->
    if @get('selectedEventType')
      event_ids = @get('selectedEventType.id').split(',')
      events = []
      for event_id in event_ids
        events = events.concat @get('controllers.events.content').filterBy('type', event_id)
      events
    else
      []
  ).property('selectedEventType.id')

  eventsDropdownVisible: ( ->
    @get('selectedEventType')? && !@get('isEventTypeIdMaterials')
  ).property('selectedEventType.id', 'isEventTypeIdMaterials')

  isEventTypeIdMaterials: ( ->
    @get('selectedEventType')? && @get('selectedEventType.id') == @get('controllers.events.idMaterialsEvent.id')
  ).property('selectedEventType')

  handleEventTypeSelection: (eventType) ->
    @set('selectedEventType', eventType)
    if @get('selectedEventType.id') != @get('selectedEvent.type')
      @set('selectedEvents', [])
      @set('selectedEventsIds', [])
    if (@get('selectedDocumentType.eventTypes') && @get('selectedDocumentType.eventTypes').indexOf(@get('selectedEvent.type')) < 0) || eventType.id == 'EcSrg'
      @set('selectedDocumentType', null)

  handleEventTypeDeselection: (eventType) ->
      @set('selectedEventType', null)
      @set('selectedEvents', [])
      @set('selectedEventsIds', [])
      @set('selectedDocumentType', null)

  actions:
    handleEventTypeSelection: @handleEventTypeSelection

    handleEventTypeDeselection: @handleEventTypeDeselection

    deleteEventSelection: (context) ->
      @get('selectedEvents').removeObject(context)
