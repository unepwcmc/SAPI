Species.EventsController = Ember.ArrayController.extend
  eventTypes: [
    {
      id: 'CoP', name: 'CoP'
    },
    {
      id: 'SRG', name: 'SRG'
    }
  ]

  content: [
    {
      id: 1,
      name: 'CoP15',
      type: 'CoP'
    },
    {
      id: 2,
      name: 'CoP16',
      type: 'CoP'
    },
    {
      id: 3,
      name: 'SRG 72',
      type: 'SRG'
    }
  ]
