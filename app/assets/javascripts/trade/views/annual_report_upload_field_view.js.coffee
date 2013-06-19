Trade.AnnualReportUploadFieldView = Ember.TextField.extend
    type: 'file'
    attributeBindings: ['name', 'controller']

    didInsertElement: ()->
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
                @get('controller').send(
                  'transitionToRoute',
                  'annual_report_upload',
                  aru
                )
              else
                @get('controller').send(
                  'transitionToRoute',
                  'annual_report_uploads'
                )
              $('#upload-message').text(file.error)
