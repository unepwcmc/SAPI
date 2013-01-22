$(document).ready ->
  editorClass = $('#admin-in-place-editor').attr('data-editor-for')
  if editorClass == 'taxon_concept'
    window.adminInPlaceEditor = new TaxonConceptsEditor()
  else
    window.adminInPlaceEditor = new AdminInPlaceEditor()
  window.adminInPlaceEditor.init()

class AdminInPlaceEditor
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

  initModals: () ->
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()

    $('.modal').on 'hidden', () ->
      form = $(@).find('form')[0]
      form.reset() if form

      $(@).find('.alert').remove()

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('h1'))

class TaxonConceptsEditor extends AdminInPlaceEditor
  initModals: () ->
    super
    $('.typeahead').typeahead
      source: (query, process) ->
        prefix = if (@$element.attr('id').match('^synonym_.+') != null)
         'synonym_'
        else
          ''
        $.get('/admin/taxon_concepts/autocomplete',
        {
          scientific_name: query,
          designation_id: $('#' + prefix + 'taxon_concept_designation_id').attr('value'),
          rank_id: $('#' + prefix + 'taxon_concept_rank_id').attr('value'),
          name_status: $('#' + prefix + 'taxon_concept_name_status').attr('value'),
          limit: 25
        }, (data) =>
          labels = []
          $.each(data, (i, item) =>
            label = item.full_name + ' ' + item.rank_name
            labels.push(label)
          )
          return process(labels)
        )
      $('#taxon_concept_designation_id, #taxon_concept_rank_id').change () ->
        $('#taxon_concept_parent_scientific_name').attr('value', null)
      $('#synonym_taxon_concept_designation_id').change () ->
        $('#synonym_taxon_concept_parent_scientific_name').attr('value', null)
