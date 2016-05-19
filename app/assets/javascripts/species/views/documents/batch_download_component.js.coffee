Species.BatchDownloadComponent = Ember.Component.extend
  tagName: 'a'
  template: Ember.Handlebars.compile('<i class="fa fa-download"></i>')

  click: (event) ->
    checked = $(event.target).closest('.inner-table-container').
      find('td.download-col input:checked')
    documentIds = checked.map( ->
      $(@).closest('tr').data('document-id')
    ).toArray()
    url = "/api/v1/documents/download_zip?ids=#{documentIds.join()}"
    $.ajax({
      type: 'GET'
      dataType: 'json'
      url: "/api/v1/documents/download_zip"
      data: { ids: documentIds.join() }
    }).done((data) =>
      debugger
      for doc in data.documents
        ga('send', {
          hitType: 'event',
          eventCategory: "Downloads: #{doc.event_type}",
          eventAction: doc.event_name,
          label: doc.document_type,
          value: doc.id
        })
    )
    window.location = url
