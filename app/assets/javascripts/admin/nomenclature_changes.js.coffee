$(document).ready ->
  defaultTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '300px'
    minimumInputLength: 3
    quietMillis: 500
    initSelection: (element, callback) =>
      id = $(element).val()
      if (id != '')
        callback({id: id, text: $(element).attr('data-name') + ' ' + $(element).attr('data-name-status')})

    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        search_params:
          scientific_name: query
          name_status: this.data('name-status-filter')
        per_page: 25
        page: 1
      results: (data, page) => # parse the results into the format expected by Select2.
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name + ' ' + tc.name_status
        results: formatted_taxon_concepts
  }
  $('.taxon-concept').select2(defaultTaxonSelect2Options)
  $('.taxon-concept.status-change').on('change', (event) ->
    statusDropdown = $('select')
    $.when($.ajax( '/admin/taxon_concepts/' + event.val + '.json' ) ).then(( data, textStatus, jqXHR ) ->
      # reload the name status dropdown based on selection
      statusFrom = data.name_status
      $(statusDropdown).find('option').attr('disabled', true);
      if statusFrom == 'A'
        $(statusDropdown).find('option[value=A]').removeAttr('selected')
        $(statusDropdown).find('option[value=N]').removeAttr('disabled')
        $(statusDropdown).find('option[value=S]').removeAttr('disabled')
      else if statusFrom == 'N'
        $(statusDropdown).find('option[value=N]').removeAttr('selected')
        $(statusDropdown).find('option[value=A]').removeAttr('disabled')
        $(statusDropdown).find('option[value=S]').removeAttr('disabled')
      else if statusFrom == 'S'
        $(statusDropdown).find('option[value=S]').removeAttr('selected')
        $(statusDropdown).find('option[value=A]').removeAttr('disabled')
        $(statusDropdown).find('option[value=N]').removeAttr('disabled')
      else if statusFrom == 'T'
        $(statusDropdown).find('option[value=T]').removeAttr('selected')
        $(statusDropdown).find('option[value=A]').removeAttr('disabled')
        $(statusDropdown).find('option[value=N]').removeAttr('disabled')
        $(statusDropdown).find('option[value=S]').removeAttr('disabled')
    )
  )

  $(document).on('nested:fieldAdded', (event) ->
    # this field was just inserted into your form
    field = event.field
    # it's a jQuery object already
    taxonField = field.find('.taxon-concept')
    # and activate select2
    taxonField.select2(defaultTaxonSelect2Options)
  )

  simpleTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '200px'
  }
  $('.simple-taxon-concept').select2(simpleTaxonSelect2Options)

  $('.select-all-checkbox').click (e) ->
      checkboxElement = $(e.target)
      selectElement = checkboxElement.parent().find('select')
      if checkboxElement.is(':checked')
        selectElement.find('option').prop("selected","selected")
      else
        selectElement.find('option').removeAttr("selected")
      selectElement.trigger("change")
