Trade.AuthoriseUser = Ember.Mixin.create

  userCanEdit: (callback) ->
    $.ajax({
      type: 'GET'
      url: "/trade/user_can_edit"
      data: {}
      dataType: 'json'
      success: (response) =>
        if response.can_edit
          callback()
        else
          alert('It is not possible to perform this action. If you require further assistance please contact the Species team on species@unep-wcmc.org')
      error: (error) ->
        console.log(error)
    })
