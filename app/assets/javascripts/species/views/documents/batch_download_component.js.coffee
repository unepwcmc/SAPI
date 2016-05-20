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

    trackingInfo = {
      hitType: 'event',
      eventCategory: "Downloads: #{@get('eventType')}",
      eventAction: 'Batch download',
      label: "Context: #{@get('searchContextInfo')} (#{@get('signedInInfo')})",
      value: documentIds.length
    }
    ga('send', trackingInfo)
    window.location = url
