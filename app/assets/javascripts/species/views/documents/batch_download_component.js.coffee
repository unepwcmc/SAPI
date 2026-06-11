Species.BatchDownloadComponent = Ember.Component.extend Species.RetryOrchestrator,
  tagName: 'a'
  template: Ember.Handlebars.compile(
    '<i class="fa {{unbound view.iconClass}}"></i>'
  )

  iconClass: (-> 'fa-download').property()

  click: (event) ->
    checked = $(event.target).closest('.inner-table-container').
      find('td.download-col input:checked')

    documentIds = checked.map( ->
      $(@).closest('tr').data('document-id')
    ).toArray()

    analytics.gtag('event', 'download_clicked', {
      download_type: @get('eventType'),
      search_context: @get('searchContextInfo'),
      count: documentIds.length
    })

    @send('requestDownloadUrl', documentIds)


  actions:
    setTableLocked: (isLocked) ->
      $(
        @get('element')
      ).closest(
        '.inner-table-container'
      ).find(
        'th.download-col input, td.download-col input, td.language-col select'
      ).attr(
        'disabled',
        isLocked
      )

    lockTable: ->
      @send('setTableLocked', true)

    unlockTable: ->
      @send('setTableLocked', false)

    requestDownloadUrl: (documentIds) ->
      vm = @
      url = "/api/v1/documents/download_zip?ids=#{documentIds.join()}"

      @send('lockTable')

      vm.send('doOrRetry', {
        delayMs: 1000,
        maxRetryCount: 60,

        onCheck: (onError, onResponse) ->
          $.ajax(
            url: url,
            success: (data) ->
              if data.error_message
                onError(data.error_message)
              else
                onResponse(data.download_url)
            error: (jqXHR, textStatus, errorThrown) ->
              onError(textStatus)
          )

        onSuccess: (directDowloadUrl) ->
          console.warn('Direct download URL: ', directDowloadUrl)

          vm.send('attemptDirectDownload', directDowloadUrl)

        onError: (e) ->
          console.error('Error while fetching dat from Rails', e)

          vm.send('unlockTable')

        onBeforeWait: ->
          console.warn('Rails says it is not ready, waiting before retry...')

        onRetriesExhausted: ->
          console.error('Rails was never ready; giving up!')

          vm.send('unlockTable')
      })

    attemptDirectDownload: (remoteUrl) ->
      vm = @

      console.log('attemptDirectDownload:', remoteUrl)

      @send('doOrRetry', {
        delayMs: 1000,
        maxRetryCount: 10,

        onCheck: (onError, onResponse) ->
          # Dummy code for testing

          $.ajax(
            url: remoteUrl,
            method: 'HEAD'
            success: (data) ->
              onResponse(remoteUrl)
            error: (jqXHR, textStatus, errorThrown) ->
              onError(textStatus)
          )

        onError: (e) ->
          console.error('Error while fetching dat from S3', e)

          vm.send('unlockTable')

        onSuccess: ->
          console.log('S3 HEAD ok: downloading from S3.')

          window.location = remoteUrl

          vm.send('unlockTable')

        onBeforeWait: ->
          console.warn('Bucket not ready, waiting before retry...')

        onRetriesExhausted: ->
          console.error('Bucket was never ready, giving up!')

          vm.send('unlockTable')
      })
