Trade.AnnualReportUploadsController = Ember.ArrayController.extend
  content: null
  needs: ['geoEntities']

  actions:
    transitionToReportUpload: (aru)->
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUploads: ()->
      @transitionToRoute('annual_report_uploads')

    onSuccess: ()->
      @transitionToRoute('annual_report_uploads')

    deleteAllReports: ()->
    	$.when($.ajax({
            type: "DELETE"
            url: "/trade/annual_report_uploads/1"
            dataType: 'json'
          }))
      
