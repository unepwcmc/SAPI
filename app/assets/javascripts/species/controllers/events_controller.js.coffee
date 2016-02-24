Species.EventsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  needs: ['elibrarySearch']

  eventTypes: [
    {
      id: 'CitesCop',
      name: 'CITES CoP'
    },
    {
      id: 'CitesAc',
      name: 'CITES Animals Committee'
    },
    {
      id: 'CitesPc',
      name: 'CITES Plants Committee'
    },
    {
      id: 'EcSrg',
      name: 'EU Scientific Review Group'
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

  documentTypes: [
    {
      id: 'Document::Proposal',
      name: 'Proposal',
      eventTypes: ['CitesCop', 'CitesExtraordinaryMeeting']
    },
    {
      id: 'Document::ReviewOfSignificantTrade',
      name: 'Review of Significant Trade',
      eventTypes: ['CitesAc', 'CitesPc', 'CitesTc']
    },
    {
      id: 'Document::MeetingAgenda',
      name: 'Meeting Agenda',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::ShortSummaryOfConclusions',
      name: 'Short Summary of Conclusions',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::AgendaItems',
      name: 'Agenda Items',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::DetailedSummaryOfConclusions',
      name: 'Detailed Summary of Conclusions',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::RangeStateConsultationLetter',
      name: 'Range State Consultation Letter',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::ListOfParticipants',
      name: 'List of Participants',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::CommissionNotes',
      name: 'Commission Notes'
    },
    {
      id: 'Document::NdfConsultation',
      name: 'NDF Consultation'
    },
    {
      id: 'Document::NonDetrimentFindings',
      name: 'Non-Detriment Findings'
    },
    {
      id: 'Document::UnepWcmcReport',
      name: 'UNEP-WCMC Report'
    }
  ]


  load: ->
    unless @get('loaded')
      @set('content', Species.Event.find())

  handleLoadFinished: ->
    @get('controllers.elibrarySearch').initEventSelector()
