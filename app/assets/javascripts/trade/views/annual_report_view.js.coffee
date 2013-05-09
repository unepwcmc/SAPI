Trade.AnnualReportView = Ember.View.extend
  templateName: 'trade/annual_report'
  submitFileUpload: ()->
    annual_report_upload = Trade.AnnualReportUpload.createRecord
      annual_report_id: 1
      attachment: @get('controller').get('source_file')
    @get('controller.store').commit()
