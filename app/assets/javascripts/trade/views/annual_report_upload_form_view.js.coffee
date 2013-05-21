Trade.AnnualReportUploadFormView = Ember.View.extend
  templateName: 'trade/annual_report_upload_form'
  didInsertElement: ()->
    $("input[type=submit]").click( (e) ->
        e.preventDefault()
    )
