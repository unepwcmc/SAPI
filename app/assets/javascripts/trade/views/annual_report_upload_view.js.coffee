Trade.AnnualReportUploadView = Ember.TextField.extend
    type: 'file'
    attributeBindings: ['name']

    didInsertElement: ()->
      @.$().fileupload
          dataType: 'json'
          url: '/trade/annual_report_uploads'
          done: (e, data) ->
            $('<p/>').text(data.result.original_filename).appendTo(document.body)
