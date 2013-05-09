Trade.AnnualReportView = Ember.View.extend
  templateName: 'trade/annual_report'
  submitFileUpload: ()->
    annual_report = Trade.AnnualReport.createRecord({ year: 2000, attachment: @get('controller').get('source_file') })
    @get('controller.store').commit()
