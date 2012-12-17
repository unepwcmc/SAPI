$(document).ready ->
  resName = $('.admin-in-place-editor').attr('id')
  new AdminInPlaceEditor(resName).init()

class AdminInPlaceEditor
  constructor: (@name) ->

  init: () ->
    $('#' + @name).find('.editable').editable
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
    $('#' + @name).find('.editable-required').editable 'option', 'validate', (v) ->
      return 'Required field!' if (v == '')

    $('.new-button').click () =>
      $('.admin-in-place-editor-new').modal()
      $('.admin-in-place-editor-new').find('.editable').editable
        placement: 'right'
    $('.admin-in-place-editor-new').find('.modal-footer').find('.save-button').click () =>
      console.log('save')
      form = $('.admin-in-place-editor-new').find('form')
      params = form.serialize()
      $.ajax
        url: form.attr('action')
        data: params
        dataType: 'JSON'
        type: 'POST'
        success: (data) -> 
          console.log(data)
          if data && data.id
            console.log 'saved'
            msg = 'New user created! Now editables submit individually.'
            $('#msg').addClass('alert-success').removeClass('alert-error').html(msg).show()
            $('#save-btn').hide()
          else if data && data.errors
            console.log 'errors'
            #server-side validation error, response like {"errors": {"username": "username already exist"} }
            config.error.call(this, data.errors)
        error: (errors) ->
          msg = ''
          if (errors && errors.responseText) #ajax error, errors = xhr object
            msg = errors.responseText
          else #validation error (client-side or server-side)
          $.each errors, (k, v) ->
            msg += (k + ": " + v + "<br>")
          $('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show()
