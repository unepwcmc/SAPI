Trade.AnnualReportUploadsController = Ember.ArrayController.extend
  content: null
  needs: ['geoEntities']

  actions:
    transitionToReportUpload: (aru)->
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUploads: ()->
      @transitionToRoute('annual_report_uploads')


    deleteAllReports: ()->
    	$.ajax({
            type: "DELETE"
            url: '/trade/annual_report_uploads/'+@get('id')
            dataType: 'json'
          })
      window.location.reload(true)


      
