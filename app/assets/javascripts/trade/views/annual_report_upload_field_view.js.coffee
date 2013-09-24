Trade.AnnualReportUploadFieldView = Ember.TextField.extend
  type: 'file'
  attributeBindings: ['name', 'controller']

  didInsertElement: ()->
    controller = @get('parentView.controller')
    @.$().fileupload
      dataType: 'json'

      add: (e, data) ->
        $("input[type=submit]").attr("disabled", null)
          .click( (e) ->
              e.preventDefault()
              data.submit()
          )

      done: (e, data) =>
        $.each data.result.files, (index, file) =>
          if file.id != undefined
            aru = Trade.AnnualReportUpload.find(file.id)
            controller.send('transitionToReportUpload', aru)
          else
            controller.send('transitionToReportUploads')
          $('#upload-message').text(file.error)
