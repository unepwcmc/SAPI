
Species.RetryOrchestrator = Ember.Mixin.create
  actions:
    doOrRetry: (options) ->
      console.log('here!')
      onCheck            = options.onCheck            || ((onCheckError) -> onCheckError(new Error('Not Implemented')))
      onSuccess          = options.onSuccess          || ((result) -> console.log('onSuccess', result))
      onError            = options.onError            || ((e) -> console.error(e))
      onBeforeWait       = options.onBeforeWait       || (() -> null)
      onRetriesExhausted = options.onRetriesExhausted || (() -> null)
      maxRetryCount      = options.maxRetryCount      || 1
      delayMs            = options.delayMs            || 1000

      # The following code orchestrates the check/retry behaviour only
      (
        (retryCount, onRetry, retry) ->
          retry(retryCount, onRetry, retry)
      )(
        maxRetryCount,
        (
          (next) ->
            onCheck(
              onError,
              (
                (result) ->
                  if result
                    onSuccess(result)
                  else
                    if next
                      onBeforeWait()
                      next()
                    else
                      onRetriesExhausted()
              )
            )
        ),
        (retryCount, onRetry, retry) ->
          if retryCount > 0
            onRetry(
              -> setTimeout(
                (-> retry(retryCount - 1, onRetry, retry)),
                delayMs
              )
            )
          else
            onRetry()
      )