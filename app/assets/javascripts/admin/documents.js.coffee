$(document).ready ->

  $('#event-id').chained('#event-type')
  $('#event_id_search').chained('#event_type_search')
  $('#document_type').chained('#event_type_search')

  # Save the children from chained destruction!
  documentTypeChildren =  $('#document_type').children()

  $('#event_type_search').change( (e) ->
    documentType = $('#document_type')
    # if no event type selected
    unless e.target.value
      # enable all document types
      documentType.prop('disabled', false)
      documentType.html(documentTypeChildren)
  )

  $('#event-link').click( (e) ->
    event_id = $('#event-id').val()
    if event_id
      $(e.target).attr('href', 'events/' + event_id + '/document_batch/new')
    else
      $(e.target).attr('href', 'document_batch/new')
  )

  $('#event-type').change( (e) ->
    newEventLink = $('#new-event-link')
    # if no event type selected
    unless e.target.value
      # disable new event link
      newEventLink.hide()
    else
      newEventLink.attr('href', $(this).find('option:selected').data('path'))
      newEventLink.show()
  )

  primaryDocumentSelect2Options = {
    placeholder: 'Start typing title'
    width: '500px'
    minimumInputLength: 3
    quietMillis: 500
    allowClear: true
    initSelection: (element, callback) ->
      callback($(element).data('init-selection'))
    ajax:
      url: '/admin/documents/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        {
          title: query
          event_id: $('#document_event_id').val()
        }
      results: (data, page) ->
        formatted_documents = data.map (doc) =>
          id: doc.id
          text: doc.title
        results: formatted_documents
  }

  citationTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    multiple: true
    width: '300px'
    minimumInputLength: 3
    quietMillis: 500
    allowClear: true
    initSelection: (element, callback) ->
      callback($(element).data('init-selection'))
    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        {
          search_params:
            scientific_name: query
            name_status: $(@).data('name-status-filter')
            taxonomy:
              id: $(@).data('taxonomy-id')
          per_page: 25
          page: page
        }
      results: (data, page) ->
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name
        results: formatted_taxon_concepts
  }

  citationGeoEntitySelect2Options = {
    placeholder: 'Start typing country or territory'
    width: '300px'
    allowClear: true
  }

  documentTagSelect2Options = {
    placeholder: 'Start typing a document tag'
    width: '300px'
    allowClear: true
  }

  eventsSelect2Options = {
    placeholder: 'Start typing an event'
    width: '300px'
    allowClear: true
  }

  $('.primary-language-document').select2(primaryDocumentSelect2Options)
  $('.citation-taxon-concept').select2(citationTaxonSelect2Options)
  $('.citation-geo-entity').select2(citationGeoEntitySelect2Options)
  $('.events-search').select2(eventsSelect2Options)
  $('.document-tag').select2(documentTagSelect2Options)

  $(document).on('nested:fieldAdded', (event) ->
    field = event.field
    citationTaxonField = field.find('.citation-taxon-concept')
    citationGeoEntityField = field.find('.citation-geo-entity')
    # and activate select2
    citationTaxonField.select2(citationTaxonSelect2Options)
    citationGeoEntityField.select2(citationGeoEntitySelect2Options)
  )

  $('ul.documents-reorder-list').sortable(
    items: 'li'
  ).bind('sortupdate', (e, ui) ->
    ui.startparent.find('input').each( (idx) ->
      $(@).val(idx)
    )
  )
