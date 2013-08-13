$(document).ready ->
  console.log(window.editorClass)
  if window.editorClass == 'taxon_concepts'
    window.adminEditor = new TaxonConceptsEditor()
  else if window.editorClass == 'listing_changes' 
    window.adminEditor = new ListingChangesEditor()
  else
    window.adminEditor = new AdminInPlaceEditor()
  window.adminEditor.init()

class AdminEditor
  init: () ->
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()
    $('.modal').on 'hidden', () =>
      @clearModalForm($(@))
    @initModals()

  clearModalForm: (modal) ->
    form = modal.find('form')
    form[0].reset() if form.length > 0

  initForm: () ->
    $(".datepicker").datepicker
      format: "dd/mm/yyyy",
      autoclose: true

  initModals: () ->
    $(@).find('.alert').remove()

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('h1'))

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
        #originally params contain pk, name and value
        newParams = id: params.pk
        newParams[$(@).attr('data-resource')] = {}
        newParams[$(@).attr('data-resource')][params.name] = params.value
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

class TaxonConceptsEditor extends AdminEditor
  init: () ->
    super
    $('.modal .modal-footer .save-and-reopen-button').click () =>
      @saveAndReopen = true

  initModals: () ->
    super
    @saveAndReopen = false
    @initTaxonConceptTypeaheads()
    @initReferencesTypeahead()
    $('.distributions-list > a').popover({});

  initTaxonConceptTypeaheads: () ->
    $('.search-typeahead').typeahead
      source: (query, process) ->
        $.get('/admin/taxon_concepts/autocomplete',
        {
          search_params: {
            scientific_name: query,
            taxonomy: {
              id: $('#search_params_taxonomy_id').val()
            }
          }
          limit: 25
        }, (data) =>
          labels = []
          $.each(data, (i, item) =>
            label = item.full_name
            labels.push(label)
          )
          return process(labels)
        )

    $('input.typeahead').each (idx) ->
      formId = $(@).closest('form').attr('id')

      if formId?
        matches = formId.match('^(.+_)?(new|edit)_(.+)$')
        prefix = matches[3]
        prefix = matches[1] + prefix unless matches[1] == undefined

        taxonomyEl = $('#' + prefix + '_taxonomy_id')
        rankEl = $('#' + prefix + '_rank_id')

        #initialize this typeahead
        $(@).typeahead
          source: (query, process) ->
            $.get('/admin/taxon_concepts/autocomplete',
            {
              search_params: {
                scientific_name: query,
                taxonomy: {
                  id: taxonomyEl && taxonomyEl.val() || $(@).attr('data-taxonomy-id')
                },
                rank: {
                  id: rankEl && rankEl.val() || $(@).attr('data-rank-id'),
                  scope: $(@).attr('data-rank-scope')
                }
              }
              limit: 25
            }, (data) =>
              labels = []
              $.each(data, (i, item) =>
                label = item.full_name + ' ' + item.rank_name
                labels.push(label)
              )
              return process(labels)
            )
          $().add(taxonomyEl).add(rankEl).change () =>
            $(@).val(null)

  initReferencesTypeahead: () ->
    @references = {}
    @referencesLabels = []
    $('.references-typeahead').typeahead(
      source: (query, process) =>
        $.get(
          '/admin/references/autocomplete',
          { query: query },
          (data) =>
            _.each(data, (item, i, list) =>
              if (_.has(@references, item.value))
                item.value = item.value + ' (' + item.id + ')'

              @referencesLabels.push(item.value)
              @references[item.value] = item.id
            )
            process(@referencesLabels)
        )
      updater: (item) =>
        $('#reference_id').val(@references[item])
        $('#reference_search').val(item)
        return item
    )

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('.modal-body form'))

class ListingChangesEditor extends AdminEditor
  init: () ->
    @initEditors()
    @initForm()

  initEditors: () ->
    $("[rel='tooltip']").tooltip()

  initForm: () ->
    super
    @initTaxonConceptTypeaheads()
    @initDistributionSelectors()
    @initEventSelector()
    # handle initializing stuff for nested form add events
    $(document).on('nested:fieldAdded', (event) =>
      event.field.find('.distribution').select2({
        placeholder: 'Select countries'
      })
      @_initTaxonConceptTypeaheads(event.field.find('.typeahead'))
    )

  initTaxonConceptTypeaheads: () ->
    @_initTaxonConceptTypeaheads($('.typeahead'))

  _initTaxonConceptTypeaheads: (el) ->
    el.typeahead
      source: (query, process) ->
        $.get('/admin/taxon_concepts/autocomplete',
        {
          search_params: {
            scientific_name: query,
            taxon_concept: {
              id: @.$element.attr('data-taxon-concept-id'),
              scope: @.$element.attr('data-taxon-concept-scope')
            }
          }
          limit: 25
        }, (data) =>
          labels = []
          $.each(data, (i, item) =>
            label = item.full_name + ' ' + item.rank_name
            labels.push(label)
          )
          return process(labels)
        )

  initDistributionSelectors: () ->
    $('.distribution:not(#exclusions_fields_blueprint > .fields > select)').select2({
      placeholder: 'Select countries'
    })

    $("#excluded_taxon_concepts_ids").select2({
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

  initEventSelector: () ->
    if $('#cites_cop').length > 0
      $('#listing_change_hash_annotation_id').chained('#cites_cop')
    else
      $('#listing_change_hash_annotation_id').chained('#listing_change_event_id')
