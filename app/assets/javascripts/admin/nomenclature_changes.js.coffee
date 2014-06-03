$(document).ready ->
  defaultTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '200px'
    minimumInputLength: 3
    quietMillis: 500,
    initSelection: (element, callback) =>
      id = $(element).val()
      if (id != '')
        $.ajax("/api/v1/taxon_concepts/"+id+".json").
          done((data) ->
            callback({id: id, text: data.taxon_concept.full_name})
          )

    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        search_params:
          scientific_name: query
        per_page: 25
        page: 1
      results: (data, page) => # parse the results into the format expected by Select2.
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name
        results: formatted_taxon_concepts
  }
  $('.taxon-concept').select2(defaultTaxonSelect2Options)

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
      console.log(selectElement)
      if checkboxElement.is(':checked')
        selectElement.find('option').prop("selected","selected")
      else
        selectElement.find('option').removeAttr("selected")
      selectElement.trigger("change")
