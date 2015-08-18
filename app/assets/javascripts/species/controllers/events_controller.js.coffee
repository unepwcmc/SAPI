Species.EventsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  eventTypes: [
    {
      id: 'CitesCop',
      name: 'CITES CoP'
    },
    {
      id: 'CitesAc',
      name: 'CITES Animal Committee'
    },
    {
      id: 'CitesPc',
      name: 'CITES Plant Committee'
    },
    {
      id: 'EcSrg',
      name: 'EC SRG'
    },
    {
      id: 'CitesTc',
      name: 'CITES Technical Committee'
    },
    {
      id: 'CitesExtraordinaryMeeting',
      name: 'CITES Extraordinary Meeting'
    }
  ]

  load: ->
    unless @get('loaded')
      @set('content', Species.Event.find())
