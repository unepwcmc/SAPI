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
        form = $(@).closest('form')
        taxonomySelector = form && form.find('.taxonomy-selector')
        rankSelector = form && form.find('.rank-selector')
        search_params:
          scientific_name: query
          name_status: @data('name-status-filter')
          taxonomy:
            id: taxonomySelector && taxonomySelector.val() || @data('taxonomy-id')
          rank:
            id: rankSelector && rankSelector.val() || @data('rank-id')
            scope: $(@).attr('data-rank-scope')
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
      elementValue = $(element).val()
      # Reset value attribute to let Select2 work properly when submitting the values again
      $(element).attr('value','')
      if elementValue?
        ids = elementValue.match(/({|\[)(.*)(}|\])/)[2]
        names = $(element).data('name')
        name_status = $(element).data('name-status')
        result = []
        if ids != ''
          ids = ids.split(',')
          for id, i in ids
            result.push({id: id, text: names && names[i] + ' ' + name_status})
        callback(result)
  }
  window.max2Select2Options = {
    maximumSelectionSize: 2,
    formatSelectionTooBig: (limit) ->
      return 'You can only select ' + limit + ' items'
  }

  $('.taxon-concept').select2(window.defaultTaxonSelect2Options)
  $('.taxon-concept-multiple').select2($.extend({}, window.defaultTaxonSelect2Options, window.multiTaxonSelect2Options))
  $('.taxon-concept-multiple-max-2').select2($.extend({}, window.defaultTaxonSelect2Options, window.multiTaxonSelect2Options, window.max2Select2Options))
  $('.taxon-concept').on('change', (event) ->
    return false unless event.val
    $.when($.ajax( '/admin/taxon_concepts/' + event.val + '.json' ) ).then(( data, textStatus, jqXHR ) =>
      $(this).attr('data-name', data.full_name)
      $(this).attr('data-name-status', data.name_status)
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
      when "new_taxon"
        NewTaxonForm(this)
      when "existing_taxon"
        ExistingTaxonForm(this)
      when "existing_subspecies"
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

  ShowUpgradeInfo = (obj) ->
    $(obj).closest('.fields').find('.upgrade-info').first().show()

  HideUpgradeInfo = (obj) ->
    upgrade_info = $(obj).closest('.fields').find('.upgrade-info')
    upgrade_info.first().hide()
    upgrade_info.find('input').prop("value", '')
    $(obj).closest('.fields').find('.parent-taxon').select2('data',null)

  ShowEgLabel = (obj) ->
    $(obj).closest('.fields').find('.new-scientific-name-eg').show()

  HideEgLabel = (obj) ->
    $(obj).closest('.fields').find('.new-scientific-name-eg').hide()

  NewTaxonForm = (obj) ->
    HideInputTaxon(obj)
    ShowUpgradeInfo(obj)
    ShowEgLabel(obj)

  ExistingTaxonForm = (obj) ->
    ShowInputTaxon(obj)
    HideUpgradeInfo(obj)
    HideEgLabel(obj)

  UpgradedTaxonForm = (obj) ->
    ShowInputTaxon(obj)
    ShowUpgradeInfo(obj)
    HideEgLabel(obj)

  DefaultExistingTaxon = (obj) ->
    $(obj).find('.output-radio[value="existing_taxon"]').attr("checked","checked")
    ExistingTaxonForm(obj)

  OutputsDefaultConfiguration = ->
    $('.fields').each (index) ->
      outputType = $(this).find('input[type=radio]:checked')
      if outputType.val() == 'new_taxon'
        NewTaxonForm(this)
      else if outputType.val() == 'existing_taxon'
        ExistingTaxonForm(this)
      else
        UpgradedTaxonForm(this)

  OutputsDefaultConfiguration()
