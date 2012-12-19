$(document).ready ->
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

    $('.new-button').click () =>
      modalEl = $('#admin-new-record-modal')
      modalEl.on 'hidden', () ->
        $(@).find('form')[0].reset()
      modalEl.modal()
    $('#admin-new-record-modal .modal-footer .save-button').click () ->
      $('#admin-new-record-modal').find('form').submit()
  alertSuccess: (txt) ->
    $('.alert').remove()
    alert = "<div class=\"alert alert-success\">" +
      "<a class=\"close\" href=\"#\" data-dismiss=\"alert\">×</a>" +
      txt +
      "</div>"
    $(alert).insertBefore($('h1'))
