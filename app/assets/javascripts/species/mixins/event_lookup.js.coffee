Species.EventLookup = Ember.Mixin.create
  selectedEvent: null
  selectedEventId: null

  eventsObserver: ( ->
    Ember.run.once(@, 'initEventSelector')
  ).observes('controllers.events.@each.didLoad')

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
    @get('selectedEventType') != null
  ).property('selectedEventType.id')

  actions:
    handleEventTypeSelection: (eventType) ->
      @set('selectedEventType', eventType)

    handleEventTypeDeselection: (eventType) ->
      @set('selectedEventType', null)

    handleEventSelection: (event) ->
      @set('selectedEvent', event)

    handleEventDeselection: (event) ->
      @set('selectedEvent', null)
