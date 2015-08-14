Species.BatchDownloadComponent = Ember.Component.extend
  tagName: 'i'
  classNames: ['fa', 'fa-download']

  click: (event) ->
    button = event.target
    checked = $(button).closest('.inner-table-container').
      find('.table-body tbody tr input:checked')
    document_ids = []
    checked.each( ->
      document_ids.push($(this).closest('tr').data('document-id'))
    )
    $(button).closest('a').prop('href', '/api/v1/documents/download_zip?ids='+document_ids.join())
