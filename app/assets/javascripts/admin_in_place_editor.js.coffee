$(document).ready ->
  #editorClass = $('.editor').attr('id')
  window.adminInPlaceEditor = new AdminInPlaceEditor()
  window.adminInPlaceEditor.init()

class AdminInPlaceEditor
  init: () ->
    $('#admin-in-place-editor .editable').editable
      placement: 'right',
      ajaxOptions:
        dataType: 'json'
        type: 'put'
      params: (params) ->
        #originally params contain pk, name and value
        newParams =
          'id': params.pk
        newParams[$(@).attr 'data-resource'] = {}
        newParams[$(@).attr('data-resource')][params.name] = params.value
        return newParams
    $('#admin-in-place-editor .editable-required').editable 'option', 'validate', (v) ->
      return 'Required field!' if (v == '')
    $('#admin-in-place-editor .editable-geo-entity-type').editable(
      'option', 'source', window.geoEntityTypes
    )
    $('#admin-in-place-editor .editable-geo-relationship-type').editable(
      'option', 'source', window.geoRelationshipTypes
    )
    $('#admin-in-place-editor .editable-geo-entity').editable(
      'option', 'source', window.geoEntities
    )
    @.initModals()
  alertSuccess: (txt) ->
    $('.alert').remove()
    alert = "<div class=\"alert alert-success\">" +
      "<a class=\"close\" href=\"#\" data-dismiss=\"alert\">×</a>" +
      txt +
      "</div>"
    $(alert).insertBefore($('h1'))
  initModals: () =>
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()
    $('.modal').on 'hidden', () ->
      $(@).find('form')[0].reset()
      $(@).find('.alert').remove()
