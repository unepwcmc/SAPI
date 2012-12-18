$(document).ready ->
  new AdminInPlaceEditor().init()

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
      modalEl = $('#admin-in-place-editor-new')
      console.log modalEl
      modalEl.on 'hidden', () ->
        $(@).find('#msg').html('')
        $(@).find('form')[0].reset()
      modalEl.modal()
    $('#admin-in-place-editor-new .modal-footer .save-button').click () =>
      form = $('#admin-in-place-editor-new').find('form')
      form.submit()

      #TODO: have a look here: https://github.com/cailinanne/ujsdemo/blob/master/app/assets/javascripts/articles.js
