Trade.ValidationErrorsView = Ember.View.extend
  templateName: 'trade/annual_report_upload/validation_errors'
  classNames: ['accordion-group']

  didInsertElement: ->
    @set('defaultCollapsed', @get('collapsed'))
    if @get('controller.allErrorsCollapsed')
      @set('collapsed', true)
    $(@get('collapsibleElement')).on('hidden', =>
      @set('collapsed', true)
    )
    $(@get('collapsibleElement')).on('shown', =>
      @set('collapsed', false)
    )
    # Hide spinner when finished loading model
    $('#' + @get('collapsibleId')).ajaxStop( =>
      $('.validation-errors-loading').hide()
    )

  allErrorsCollapsedDidChange: ( ->
    # reset default collapse setting
    if @get('controller.allErrorsCollapsed') == null
      @set('collapsed', @get('defaultCollapsed'))
    else
      @set('collapsed', true)
  ).observes('controller.allErrorsCollapsed')

  toggleHint: ( ->
    if @get('collapsed')
      '>>'
    else
      '<<'
  ).property('collapsed')

  collapsibleId: ( ->
    @get('errorType') + '-validation-errors'
  ).property('errorType')

  collapsibleElement: ( ->
    '#' + @get('collapsibleId')
  ).property('collapsibleId')

  noErrorsMessage: ( ->
    if @get('errorType') == 'ignored'
      'No ignored errors'
    else
      'No errors detected'
  ).property('errorType')

  actions:

    openError: (validationError) ->
      @set('collapsed', true)
      @get('controller').send('transitionToSandboxShipments', validationError)
