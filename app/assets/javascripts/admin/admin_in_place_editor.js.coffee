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
    @initModals()

  initModals: () ->
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()

    $('.modal').on 'hidden', () ->
      $(@).find('form')[0].reset()
      $(@).find('.alert').remove()

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('h1'))

class AdminInPlaceEditor extends AdminEditor
  init: () ->
    @initEditors()
    @initModals()

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
  initTaxonConceptTypeaheads: () ->
    $('.typeahead').each (idx) ->
      formId = $(@).closest('form').attr('id')
      matches = formId.match('^(.+_)?(new|edit)_(.+)$')
      prefix = matches[3]
      prefix = matches[1] + prefix unless matches[1] == undefined

      taxonomyEl = $('#' + prefix + '_taxonomy_id')
      rankEl = $('#' + prefix + '_rank_id')
      taxonomyId = if taxonomyEl
        taxonomyEl.attr('value')
      else
        $(@).attr('data-taxonomy-id')
      rankId = if rankEl
        rankEl.attr('value')
      else
        $(@).attr('data-rank-id')

      rankScope = $(@).attr('data-rank-scope')

      #initialize this typeahead
      $(@).typeahead
        source: (query, process) ->
          $.get('/admin/taxon_concepts/autocomplete',
          {
            scientific_name: query,
            taxonomy: {id: taxonomyId},
            rank: {id: rankId, scope: rankScope},
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
          $(@).attr('value', null)

  initModals: () ->
    super
    @initTaxonConceptTypeaheads()

class ListingChangesEditor extends AdminEditor
  init: () ->
    @initEditors()
    @initModals()

  initEditors: () ->
    $("[rel='tooltip']").tooltip()

  initModals: () ->
    super
    @initForm()

  initForm: () ->
    @initTaxonConceptTypeaheads()
    @initDistributionSelectors()
    $(".datepicker").datepicker
      format: "dd/mm/yyyy",
      autoclose: true
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
          scientific_name: query,
          taxon_concept: {
            id: @.$element.attr('data-taxon-concept-id'),
            scope: @.$element.attr('data-taxon-concept-scope')
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
