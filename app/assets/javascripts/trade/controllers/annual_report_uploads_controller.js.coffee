Trade.AnnualReportUploadsController = Ember.ArrayController.extend
  content: null
  needs: ['geoEntities']

  actions:
    transitionToReportUpload: (aru)->
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUploads: ()->
      @transitionToRoute('annual_report_uploads')

    deleteAllReports: ()->

	$.when($.ajax({
        type: "DELETE"
        url: "/trade/annual_report_uploads/#{@get('id')}/submit"
        dataType: 'json'
      })).then(onSuccess, onError)
      
