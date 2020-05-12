Species.DocumentResultComponent = Ember.Component.extend
  layoutName: 'species/components/document-result'
  tagName: 'tr'
  attributeBindings: ['documentId:data-document-id'],

  setup: ( ->
    primaryDocumentId = parseInt(@get('doc.primary_document_id'))
    primaryDocumentVersion = @get('doc.document_language_versions').findBy('id', primaryDocumentId)
    # when things went wrong with translations
    unless primaryDocumentVersion
      primaryDocumentVersion = @get('doc.document_language_versions.firstObject')
    primaryLanguage = primaryDocumentVersion['language']
    allLanguages = @get('doc.document_language_versions').mapBy('language').sort()

    @setProperties(
      language: primaryLanguage,
      languages: allLanguages,
      moreThanOneLanguage: allLanguages.length > 1
    )
  ).on("init")

  meetingTitle: ( -> 
    if @get('doc.event_type') == 'IdMaterials'
      return ''
    
    return @get('doc.event_name')
  ).property('doc.event_type', 'doc.event_name')

  date: ( -> 
    date = @get('doc.date')

    if @get('doc.event_type') == 'IdMaterials'
      return date.split('/')[2]
    
    return date
  ).property('doc.date', 'doc.event_type')

  documentVersion: ( ->
    @get('doc.document_language_versions').findBy('language', @get('language'))
  ).property('language')

  documentId: ( ->
    @get('documentVersion.id')
  ).property('documentVersion.id')

  documentUrl: ( ->
    "/api/v1/documents/" + @get('documentId')
  ).property('documentId')

  title: ( ->
    @get('documentVersion.title')
  ).property('documentVersion.title')

  isLongTitle: ( ->
    @get('fullTitle').length > 60
  ).property('fullTitle')

  fullTitle: ( ->
    if @get('doc.event_type') == 'CitesCop'
      'Prop ' + (@get('doc.proposal_number') || '') + ': ' + @get('title')
    else
      @get('title')
  ).property('doc.event_type', 'doc.proposal_number', 'title')

  actions:
    startDownload: () ->
      url = "/api/v1/documents/#{@get('documentId')}"
      trackingInfo = {
        hitType: 'event',
        eventCategory: "Downloads: #{@get('doc.event_type')}",
        eventAction: @get('doc.event_name') + ': ' + @get('doc.document_type'),
        eventLabel: "Context: #{@get('searchContextInfo')} (#{@get('signedInInfo')})",
        eventValue: 1
      }
      ga('send', trackingInfo)
      window.open(url, '_blank')
