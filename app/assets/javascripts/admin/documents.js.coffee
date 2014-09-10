$(document).ready ->

  $('#document-created-end, #document-created-start').datepicker(
    format: 'dd/mm/yyyy'
  )

  $('#event-id').chained('#event-type')
  $('#event-id-search').chained('#event-type-search')
  $('#document-type').chained('#event-type-search')

  # Save the children from chained destruction!
  documentTypeChildren =  $('#document-type').children()

  $('#event-type-search').change( (e) ->
    documentType = $('#document-type')
    unless e.target.value
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

  citationTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    multiple: true
    width: '300px'
    minimumInputLength: 3
    quietMillis: 500
    allowClear: true
    initSelection: (element, callback) =>
      callback($(element).data('init-selection'))
    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        search_params:
          scientific_name: query
          name_status: $(@).data('name-status-filter')
          taxonomy:
            id: $(@).data('taxonomy-id')
        per_page: 25
        page: 1
      results: (data, page) => # parse the results into the format expected by Select2.
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name
        results: formatted_taxon_concepts
  }

  citationGeoEntitySelect2Options = {
    placeholder: 'Start typing country or territory'
  }

  $('.citation-taxon-concept').select2(citationTaxonSelect2Options)
  $('.citation-geo-entity').select2(citationGeoEntitySelect2Options)

  $(document).on('nested:fieldAdded', (event) ->
    # this field was just inserted into your form
    field = event.field
    # it's a jQuery object already
    citationTaxonField = field.find('.citation-taxon-concept')
    citationGeoEntityField = field.find('.citation-geo-entity')
    # and activate select2
    citationTaxonField.select2(citationTaxonSelect2Options)
    citationGeoEntityField.select2(citationGeoEntitySelect2Options)
  )
