$(document).ready ->
  window.defaultTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '300px'
    minimumInputLength: 3
    quietMillis: 500
    allowClear: true
    initSelection: (element, callback) =>
      id = $(element).val()
      if (id != null && id != '')
        callback({id: id, text: $(element).data('name') + ' ' + $(element).data('name-status')})

    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        search_params:
          scientific_name: query
          name_status: this.data('name-status-filter')
          taxonomy:
            id: this.data('taxonomy-id')
        per_page: 25
        page: 1
      results: (data, page) => # parse the results into the format expected by Select2.
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name + ' ' + tc.name_status
        results: formatted_taxon_concepts
  }
  window.multiTaxonSelect2Options = {
    multiple: true,
    initSelection: (element, callback) =>
      id = $(element).val().match(/({|\[)(.*)(}|\])/)[2]
      # Reset value attribute to let Select2 work properly when submitting the values again
      $(element).attr('value','')
      if (id != null && id != '')
        ids = id.split(',')
        names = $(element).data('name')
        name_status = $(element).data('name-status')
        result = []
        for id, i in ids
          result.push({id: id.trim(), text: names[i] + ' ' + name_status})
        callback(result)
  }

  $('.taxon-concept').select2(window.defaultTaxonSelect2Options)
  $('.taxon-concept-multiple').select2($.extend({}, window.defaultTaxonSelect2Options, window.multiTaxonSelect2Options))
  $('.taxon-concept').on('change', (event) ->
    return false unless event.val
    $.when($.ajax( '/admin/taxon_concepts/' + event.val + '.json' ) ).then(( data, textStatus, jqXHR ) =>
      $(this).attr('data-name', data.full_name)
      $(this).attr('data-name-status', data.name_status)
      if $(this).hasClass('status-change')
        # reload the name status dropdown based on selection
        statusDropdown = $(this).closest('.fields').find('select')
        statusFrom = data.name_status
        $(statusDropdown).find('option').attr('disabled', true)
        statusMap =
          'A': ['S']
          'N': ['A', 'S']
          'S': ['A']
          'T': ['A', 'S']
        $(statusDropdown).find('option[value=' + statusFrom + ']').removeAttr('selected')
        defaultStatus = statusMap[statusFrom][0]
        $(statusDropdown).find('option[value=' + defaultStatus + ']').attr('selected', true)
        $.each(statusMap[statusFrom], (i, status) ->
          $(statusDropdown).find('option[value=' + status + ']').removeAttr('disabled')
        )
    )
    if $(this).hasClass('clear-others')
      # reset selection in other taxon concept select2 instances
      $('input.taxon-concept').not($(this)).each((i, ac) ->
        $(ac).select2('val', '')
        $(ac).removeAttr('data-name')
        $(ac).removeAttr('data-name-status')
      )
  )

  $(document).on('nested:fieldAdded', (event) ->
    # this field was just inserted into your form
    field = event.field
    # it's a jQuery object already
    taxonField = field.find('.taxon-concept')
    # and activate select2
    taxonField.select2(window.defaultTaxonSelect2Options)
  )

  simpleTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '200px'
  }
  $('.simple-taxon-concept').select2(simpleTaxonSelect2Options)
  .on('select2-removed', (event) ->
    $(this).closest('.controls').find('.select-all-checkbox').prop('checked', false)

    $('.species-checkbox:contains('+event.choice.text+')')
    .find('.select-partial-checkbox').prop('checked', false)
  )

  $('.select-all-checkbox').click (e) ->
      checkboxElement = $(e.target)
      selectElement = checkboxElement.parent().find('select')
      if checkboxElement.is(':checked')
        selectElement.find('option').prop("selected","selected")
      else
        selectElement.find('option').removeAttr("selected")
      selectElement.trigger("change")

  $('.select-partial-checkbox').click (e) ->
      checkboxElement = $(e.target)
      species = $(checkboxElement).parent().find('span').text()
      selectElement = checkboxElement.parent().parent().find('select')
      if checkboxElement.is(':checked')
        selectElement.find('option:contains('+species+')').prop("selected","selected")
      else
        selectElement.find('option:contains('+species+')').removeAttr("selected")
      selectElement.trigger("change")

  $('form').on('click', '.output-radio', (e) ->
    value = $(this).val()
    switch value
      when "New taxon"
        NewTaxonForm(this)
      when "Existing taxon"
        ExistingTaxonForm(this)
      when "Existing subspecies"
        UpgradedTaxonForm(this)
  )

  HideInputTaxon = (obj) ->
    input_taxon = $(obj).closest('.fields').find('.input-taxon')
    input_taxon.select2('data',null)
    input_taxon.hide()
    input_taxon.closest('.control-group').find('label').hide()

  ShowInputTaxon = (obj) ->
    input_taxon = $(obj).closest('.fields').find('.input-taxon')
    input_taxon.show()
    input_taxon.closest('.control-group').find('label').show()

  HideUpgradeInfo = (obj) ->
    upgrade_info = $(obj).closest('.fields').find('.upgrade-info')
    upgrade_info.first().hide()
    upgrade_info.find('input').prop("value", '')
    $(obj).closest('.fields').find('.parent-taxon').select2('data',null)

  NewTaxonForm = (obj) ->
    HideInputTaxon(obj)
    $(obj).closest('.fields').find('.upgrade-info').first().show()

  ExistingTaxonForm = (obj) ->
    ShowInputTaxon(obj)
    HideUpgradeInfo(obj)

  UpgradedTaxonForm = (obj) ->
    ShowInputTaxon(obj)
    $(obj).closest('.fields').find('.upgrade-info').first().show()

  DefaultExistingTaxon = (obj) ->
    $(obj).find('.output-radio[value="Existing taxon"]').attr("checked","checked")
    ExistingTaxonForm(obj)

  OutputsDefaultConfiguration = ->
    $('.fields').each (index) ->
      taxon_concept = $(this).find('input.input-taxon')
      parent = $(this).find('input.parent-taxon')

      if typeof taxon_concept.attr("data-name") == 'undefined'
        $(this).find('.output-radio[value="New taxon"]').attr("checked","checked")
        NewTaxonForm(this)
      else if typeof parent.attr("data-name") == 'undefined'
        $(this).find('.output-radio[value="Existing taxon"]').attr("checked","checked")
        ExistingTaxonForm(this)
      else
        $(this).find('.output-radio[value="Existing subspecies"]').attr("checked","checked")
        UpgradedTaxonForm(this)

  OutputsDefaultConfiguration()
