Trade.AnnualReportUploadsController = Ember.ArrayController.extend
  content: null
  needs: ['geoEntities']

  deleteUpload: (aru) ->
    if (!aru.get('isSaving'))
      aru.one('didDelete', @, ->
        @get('content').removeObject(aru)
        @transitionToRoute('annual_report_uploads')
      )
      aru.deleteRecord()
      aru.get('transaction').commit()    

  actions:
    transitionToReportUpload: (aru)->
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUploads: ()->
      @transitionToRoute('annual_report_uploads')

    deleteUpload: (aru) ->
      if confirm("This will delete the upload. Proceed?")
        @deleteUpload(aru)

    deleteAllUploads: ()->
      if confirm("This will delete all uploads. Proceed?")
        @get('content').forEach (aru) =>
          @deleteUpload(aru)
     