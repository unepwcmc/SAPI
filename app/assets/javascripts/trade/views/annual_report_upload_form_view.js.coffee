Trade.AnnualReportUploadFormView = Ember.View.extend
  templateName: 'trade/annual_report_upload_form'
  didInsertElement: ()->
    $("input[type=submit]").click( (e) ->
        e.preventDefault()
    )

  fileInput: Ember.TextField.extend
    type: 'file'
    attributeBindings: ['name', 'controller']

    didInsertElement: ()->
      controller = @get('parentView.controller')
      @.$().fileupload
        dataType: 'json'

        add: (e, data) =>
          @set('parentView.fileName', data.files[0] && data.files[0].name)
          $("input[type=submit]").attr("disabled", null)
            .click( (e) ->
                e.preventDefault()
                $('#upload-message').text('Uploading...')
                data.submit()
            )
        done: (e, data) =>
          $.each data.result.files, (index, file) =>
            if file.id != undefined
              $('#upload-message').text('Upload finished')
              aru = Trade.AnnualReportUpload.find(file.id)
              controller.send('transitionToReportUpload', aru)
            else
              controller.send('transitionToReportUploads')
            $('#upload-message').text(file.error)