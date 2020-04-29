Species.EventsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  needs: ['elibrarySearch']

  eventTypes: [
    {
      id: 'CitesCop',
      name: 'CITES CoP Proposals'
    },
    {
      id: 'CitesAc,CitesTc',
      name: 'CITES Review of Significant Trade (animals)'
    },
    {
      id: 'CitesPc',
      name: 'CITES Review of Significant Trade (plants)'
    },
    {
      id: 'EcSrg',
      name: 'EU Scientific Review Group'
    }
  ]

  idMaterialsEvent: {
    id: 'IdMaterials'
    name: 'Identification Materials'
  }

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
    }
  ]

  interSessionalNonPublicDocumentTypes: [
    {
      id: 'Document::CommissionNotes',
      name: 'Commission Notes'
    }
  ]

  interSessionalDocumentTypes: [
    {
      id: 'Document::NonDetrimentFindings',
      name: 'Non-Detriment Findings'
    },
    {
      id: 'Document::UnepWcmcReport',
      name: 'UNEP-WCMC Report'
    }
  ]

  identificationDocumentTypes: [
    {
      id: '__all__',
      name: 'All'
    },
    {
      id: 'Document::IdManual',
      name: 'CITES ID Manual'
    },
    {
      id: 'Document::VirtualCollege',
      name: 'Other identification materials'
    }
  ]

  generalSubTypes: [
    {
      id: 'general',
      name: 'Whole animals/plants'
    },
    {
      id: 'parts',
      name: 'Parts and derivatives'
    }
  ]

  load: ->
    unless @get('loaded')
      @set('content', Species.Event.find())
