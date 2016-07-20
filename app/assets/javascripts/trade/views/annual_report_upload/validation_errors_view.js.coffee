Trade.ValidationErrorsView = Ember.View.extend
  templateName: 'trade/annual_report_upload/validation_errors'
  classNames: ['accordion-group']

  didInsertElement: ->
    $(@get('collapsibleElement')).on('hidden', =>
      @set('collapsed', true)
    )
    $(@get('collapsibleElement')).on('shown', =>
      @set('collapsed', false)
    )

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
