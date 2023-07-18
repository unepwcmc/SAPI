Species.DownloadsForCitesProcessesController = Ember.Controller.extend
  designation: 'cites'

  needs: ['downloads']

  processType: 'Both'

  toParams: ( ->
    {
      data_type: 'Processes'
      filters: 
        process_type: @get('processType')
        csv_separator: @get('controllers.downloads.csvSeparator')
    }
  ).property(
    'processType',
    'controllers.downloads.csvSeparator'
  )

  downloadUrl: ( ->
    '/species/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')

  actions:
    startDownload: () ->
      @set('downloadInProgress', true)
      @set('downloadMessage', 'Downloading...')
      $.ajax({
        type: 'GET'
        dataType: 'json'
        url: @get('downloadUrl')
      }).done((data) =>
        @set('downloadInProgress', false)
        if data.total > 0
          @set('downloadMessage', null)
          ga('send', {
            hitType: 'event',
            eventCategory: 'Downloads: ' + @get('processType'),
            eventAction: 'Format: CSV',
            eventLabel: @get('controllers.downloads.csvSeparator')
          })
          window.location = @get('downloadUrl')
          return
        else
          @set('downloadMessage', 'No results')
      )
