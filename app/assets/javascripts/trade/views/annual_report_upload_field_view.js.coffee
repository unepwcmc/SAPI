Trade.AnnualReportUploadFieldView = Ember.TextField.extend
    type: 'file'
    attributeBindings: ['name', 'controller']

    didInsertElement: ()->
      @.$().fileupload
          dataType: 'json'
          url: '/trade/annual_report_uploads'
          done: (e, data) =>
            aru = Trade.AnnualReportUpload.find(data['result']['annual_report_upload']['id'])
            @get('controller').send(
              'transitionToRoute',
              'annual_report_upload',
              aru
            )
