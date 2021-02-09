$(document).ready ->
  if window.editorClass == 'taxon_concepts'
    window.adminEditor = new TaxonConceptsEditor()
  else if window.editorClass == 'taxon_listing_changes' or\
  window.editorClass == 'listing_changes'
    window.adminEditor = new ListingChangesEditor()
  else if window.editorClass == 'taxon_concept_references'
    window.adminEditor = new TaxonReferencesEditor()
  else if window.editorClass == 'term_pairings_select2'
    window.adminEditor = new TermPairingsSelect2Editor()
  else if window.editorClass == 'term_pairings_select2_unit'
    window.adminEditor = new TermPairingsSelect2Editor({trade_type: 'unit'})
  else if window.editorClass == 'term_pairings_select2_purpose'
    window.adminEditor = new TermPairingsSelect2Editor({trade_type: 'purpose'})
  else
    window.adminEditor = new AdminInPlaceEditor()
  window.adminEditor.init()

class AdminEditor
  init: () ->
    @initModals()
    @initSearchTypeahead()
    $("[rel='tooltip']").tooltip()

  clearModalForm: (modalElement) ->
    modalElement.find('form').each(() ->
      @reset()
    )
    $('.taxon-concept').select2('data', null)
    $('.taxon-concept-multiple').select2('data', null)
    $('.taxon-concept-multiple-max-2').select2('data', null)

  initForm: () ->
    $(".datepicker").datepicker
      format: "dd/mm/yyyy",
      autoclose: true

  initModals: () ->
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()
    $('.modal').on 'hidden', () =>
      $('.modal.hide.fade').each((idx, element) =>
        @clearModalForm($(element))
      )
    $(@).find('.alert').remove()

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('.admin-header'))

  alertError: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-error">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('.admin-header'))

  initSearchTypeahead: () ->
    $('.search-typeahead').typeahead
      source: (query, process) ->
        $.get('/admin/taxon_concepts/autocomplete',
        {
          search_params: {
            scientific_name: query,
            taxonomy: {
              id: $('#search_params_taxonomy_id').val()
            },
            name_status: $('#search_params_name_status').val()
          }
          limit: 25
        }, (data) =>
          labels = []
          $.each(data, (i, item) =>
            labels.push(item.full_name)
          )
          return process(labels)
        )

  excludeTaxonConceptsIds: () ->
    $("#excluded_taxon_concepts_ids").select2({
      placeholder: 'Select taxa'
      minimumInputLength: 3
      multiple: true
      initSelection: (element, callback) ->
        data = []
        ids = []
        $(element.val().split(",")).each(() ->
          tmp = this.split(":")
          ids.push(tmp[0])
          data.push({id: tmp[0], text: tmp[1]})
        )
        element.val(ids)
        callback(data)
      ajax: {
        url: '/admin/taxon_concepts/autocomplete',
        dataType: 'json',
        quietMillis: 100,
        data: (query) ->
          search_params:
            scientific_name: query
            taxon_concept:
              id: $("#excluded_taxon_concepts_ids").attr('data-taxon-concept-id')
              scope: $("#excluded_taxon_concepts_ids").attr('data-taxon-concept-scope')
          limit: 25
        results: (data) ->
            results = []
            $.each(data, (i, e) ->
              results.push(
                id: e.id
                text: e.full_name
              )
            )
            results: results
        dropdownCssClass: 'bigdrop'
        placeholder: 'Select taxa'
      }
    })

  initSelect2Inputs: () ->
    $('.taxon-concept').select2(window.defaultTaxonSelect2Options)
    $('.taxon-concept-multiple').select2($.extend({}, window.defaultTaxonSelect2Options,window.multiTaxonSelect2Options))
    $('.taxon-concept-multiple-max-2').select2($.extend({}, window.defaultTaxonSelect2Options, window.multiTaxonSelect2Options, window.max2Select2Options))

class AdminInPlaceEditor extends AdminEditor
  init: () ->
    super
    @initEditors()

  initEditors: () ->
    $('#admin-in-place-editor .editable').editable
      placement: 'right'
      ajaxOptions:
        dataType: 'json'
        type: 'put'
      params: (params) ->
        value = params.value
        if params.name == 'is_current'
          value = params.value[0] || false
        #originally params contain pk, name and value
        newParams = id: params.pk
        newParams[$(@).attr('data-resource')] = {}
        newParams[$(@).attr('data-resource')][params.name] = value
        return newParams

    $('a[data-toggle="popover"]').popover(html: true, placement: 'bottom')

    $('#admin-in-place-editor .editable-required').editable('option',
      validate: (v) ->
        return 'Required field!' if (v == '')
    )

    $('#admin-in-place-editor .editable-geo-entity-type').editable(
      'option', 'source', window.geoEntityTypes
    )

    $('#admin-in-place-editor .editable-geo-relationship-type').editable(
      'option', 'source', window.geoRelationshipTypes
    )

    $('#admin-in-place-editor .editable-geo-entity').editable(
      'option', 'source', window.geoEntities
    )

    $('#admin-in-place-editor .editable-is-current').editable(
      'option', 'source', [{value: 1, text: 'current'}]
    )

    $('#admin-in-place-editor .editable-is-current').editable(
      'option', 'emptytext', 'not current'
    )

class TaxonConceptsEditor extends AdminEditor
  init: () ->
    super
    $('.modal .modal-footer .save-and-reopen-button').click () =>
      @saveAndReopen = true

  initModals: () ->
    super
    @saveAndReopen = false
    $('.distributions-list > a').popover({});

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('.modal-body form'))

class ListingChangesEditor extends AdminEditor
  init: () ->
    @initForm()
    $("[rel='tooltip']").tooltip()

  initForm: () ->
    super
    @initDistributionSelectors()
    @initEventSelector()
    # handle initializing stuff for nested form add events
    $(document).on('nested:fieldAdded', (event) =>
      event.field.find('.distribution').select2({
        placeholder: 'Select countries'
      })
    )

  initDistributionSelectors: () ->
    $('.distribution:not(#exclusions_fields_blueprint > .fields > select)').select2({
      placeholder: 'Select countries'
    })

    @excludeTaxonConceptsIds()

    $("#inclusion_taxon_concept_id").select2({
      placeholder: 'Select taxon'
      minimumInputLength: 3
      initSelection: (element, callback) ->
        tmp = element.val().split(":")
        id = tmp[0]
        data = {id: tmp[0], text: tmp[1]}
        element.val(id)
        callback(data)
      ajax: {
        url: '/admin/taxon_concepts/autocomplete',
        dataType: 'json',
        quietMillis: 100,
        data: (query) ->
          search_params:
            scientific_name: query
            taxon_concept:
              id: $("#inclusion_taxon_concept_id").attr('data-taxon-concept-id')
              scope: $("#inclusion_taxon_concept_id").attr('data-taxon-concept-scope')
          limit: 25
        results: (data) ->
            results = []
            $.each(data, (i, e) ->
              results.push(
                id: e.id
                text: e.full_name
              )
            )
            results: results
        dropdownCssClass: 'bigdrop'
        placeholder: 'Select taxa'
      }
    })

  initEventSelector: () ->
    $('#listing_change_hash_annotation_id').chained('#listing_change_event_id')
    if $('#listing_change_event_id').attr('data-designation') == 'EU'
      $('#listing_change_event_id').change((e) ->
        $.get(
          '/admin/events/' + $('#listing_change_event_id option:selected').val(),
          {format: 'json'},
          (data) ->
            $('#listing_change_effective_at').val(data.event.effective_at_formatted)
        )
      )
    $('#listing_change_event_id').change((e) ->
      if $(this).val() == ""
        $('#listing_change_hash_annotation_id').removeAttr("disabled")
    )

class TaxonReferencesEditor extends AdminEditor
  init: () ->
    super
    @nonSuperInit()

  nonSuperInit: () ->
    $(".nav-tabs.new-reference-tabs a").click (e) ->
      e.preventDefault()
      window.adminEditor.clearModalForm $("#admin-new-taxon_concept_reference-form")
      $(this).tab "show"
    @initSaveAndReOpenButton()
    @initReferencesTypeahead()
    @excludeTaxonConceptsIds()

  initSaveAndReOpenButton: () ->
    @saveAndReopen = false
    $('.modal .modal-footer .save-and-reopen-button').click () =>
      @saveAndReopen = true

  initReferencesTypeahead: () ->
    $("#reference_id").select2
      placeholder: "Type reference citation"
      minimumInputLength: 3
      ajax:
        url: "/admin/references/autocomplete"
        dataType: "json"
        quietMillis: 100
        data: (query) ->
          query: query

        results: (data) ->
          results = []
          $.each data, (i, e) ->
            results.push
              id: e.id
              text: e.value


          results: results


class TermPairingsSelect2Editor extends AdminEditor

  constructor: (options) ->
    @options = options

  init: () ->
    super
    @terms = window.editorTermCodes
    trades = window.editorTradeCodes
    if @options?.trade_type?
      @initInline({trades: trades, terms: @terms})
      @initModal({terms: @terms})
    else
      @initInline({terms: @terms})
      @initModal({terms: @terms})

  initInline: (data) ->
    @inlineOptionsArr = @getOptions($('#admin-in-place-editor .editable'), data)
    for options in @inlineOptionsArr
      @initInlineEditors(options)

  initModal: (data) ->
    data ||= {terms: @terms}
    @modalOptionsArr = @getOptions($('form .select22'), data)
    for options in @modalOptionsArr
      @initModalEditors(options)

  getOptions: (selection, data) ->
    terms = data.terms
    trades = data.trades
    options = []
    selection.each( (i) ->
      options.push {}
      selection = $(@)
      if selection.hasClass('taxon_concept')
        options[i]['select2'] =
          ajax:
            url: "/api/v1/auto_complete_taxon_concepts.json"
            dataType: "json"
            data: (term, page) ->
              taxon_concept_query: term
              visibility: 'trade_internal'
              per_page: 10
              page: page
            results: (data, page) ->
              more = (page * 10) < data.meta.total
              results: data.auto_complete_taxon_concepts.map (t) =>
                id: t.id
                name: t.full_name
              more: more
          placeholder: "Select Taxon"
          allowClear: true
          minimumInputLength: 3
          id: (item) ->
            item.id
          formatResult: (item) ->
            item.name
          formatSelection: (item) ->
            item.name
      else if selection.hasClass('term')
        options[i]['select2'] =
          data:{ results: terms, text: 'code' },
          placeholder: "Select Term"
          allowClear: true
          minimumInputLength: 1
          id: (item) ->
            item.id
          formatResult: (item) ->
            item.code
          formatSelection: (item) ->
            item.code
      else if selection.hasClass('trade')
        options[i]['select'] =
          source: trades
      options[i]['selection'] = selection
    )
    options

  initInlineEditors: (options) ->
    options.selection.editable
      placement: 'right'
      ajaxOptions:
        dataType: 'json'
        type: 'put'
      params: (params) ->
        #originally params contain pk, name and value
        newParams = id: params.pk
        newParams[$(@).attr('data-resource')] = {}
        newParams[$(@).attr('data-resource')][params.name] = params.value
        return newParams
      error: ->
        errors = arguments[0].responseText
        errorsMessages = []
        if typeof errors is 'string'
          errorMessages = errors
        else
          errors = JSON.parse(errors).errors
          for k, v of errors
            errorsMessages.push v
          errorsMessages.join ', '
      display: (item) ->
        # Hack around: https://github.com/vitalets/x-editable/issues/431
        if $(@).attr('data-type') == 'select'
          choice = $('.input-medium').find(":selected").text()
        else
          choice = $('.select2-container .select2-choice span').last().text()
        if choice then $(this).text(choice)
      select2: options.select2
      source: options.select?.source

  initModalEditors: (options) ->
    if options.select2?
      options.selection.select2 options.select2

