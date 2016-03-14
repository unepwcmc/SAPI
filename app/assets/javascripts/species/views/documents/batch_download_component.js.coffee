Species.BatchDownloadComponent = Ember.Component.extend
  tagName: 'a'
  template: Ember.Handlebars.compile('<i class="fa fa-download"></i>')

  click: (event) ->
    checked = $(event.target).closest('.inner-table-container').
      find('td.download-col input:checked')
    documentIds = checked.map( ->
      $(@).closest('tr').data('document-id')
    ).toArray()
    @.$().prop('href', '/api/v1/documents/download_zip?ids=' +
      documentIds.join()
    )
