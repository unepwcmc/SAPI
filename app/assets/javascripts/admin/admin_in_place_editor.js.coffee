$(document).ready ->
  if window.editorClass == 'taxon_concepts'
    window.adminEditor = new TaxonConceptsEditor()
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

<<<<<<< HEAD
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
=======
class TaxonConceptsEditor extends AdminEditor
  initTaxonConceptTypeaheads: () ->
    $('.typeahead').each (idx) ->
      formId = $(@).closest('form').attr('id')
      matches = formId.match('^(.+_)?(new|edit)_(.+)$')
      prefix = matches[3]
      prefix = matches[1] + prefix unless matches[1] == undefined
      console.log(prefix)
      
      taxonomyEl = $('#' + prefix + '_taxonomy_id')
      rankEl = $('#' + prefix + '_rank_id')
      nameStatusEl = $('#' + prefix + '_name_status')
      parentEl = $('#' + prefix + '_parent_scientific_name')
      acceptedEl = $('#' + prefix + '_accepted_scientific_name')
      hybridParentEl = $('#' + prefix + '_hybrid_parent_scientific_name')
      otherHybridParentEl = $('#' + prefix + '_other_hybrid_parent_scientific_name')
      console.log(nameStatusEl)
      #initialize this typeahead
      $(@).typeahead
        source: (query, process) ->
          $.get('/admin/taxon_concepts/autocomplete',
          {
            scientific_name: query,
            taxonomy_id: taxonomyEl.attr('value'),
            rank_id: rankEl.attr('value'),
            name_status: nameStatusEl.attr('value'),
            limit: 25
          }, (data) =>
            labels = []
            $.each(data, (i, item) =>
              label = item.full_name + ' ' + item.rank_name
              labels.push(label)
            )
            return process(labels)
          )
        $().add(taxonomyEl).add(rankEl).change () ->
          parentEl.attr('value', null)
          acceptedEl.attr('value', null) unless acceptedEl == undefined
          hybridParentEl.attr('value', null) unless hybridParentEl == undefined
          otherHybridParentEl.attr('value', null) unless otherHybridParentEl == undefined

  initModals: () ->
    super
    @initTaxonConceptTypeaheads()
