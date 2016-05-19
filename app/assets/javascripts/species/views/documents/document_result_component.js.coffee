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
      document_id = @get('doc.id')
      url = "/api/v1/documents/#{document_id}"
      $.ajax({
        type: 'GET'
        dataType: 'json'
        url: url
      }).done((data) =>
        doc = data.document_download
        ga('send', {
          hitType: 'event',
          eventCategory: "Downloads: #{doc.event_type}",
          eventAction: doc.event_name,
          label: doc.document_type,
          value: doc.id
        })
      )
      window.location = url

