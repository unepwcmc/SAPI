Trade.ValidationErrorsView = Ember.CollectionView.extend
  content: null
  classNames: ['collapse']
  itemViewClass: Ember.View.extend
    templateName: 'trade/validation_error'
  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No results")

  showMessage: 'Show errors'
  hideMessage: 'Hide errors'

  didInsertElement: ->
    @_updateErrorDisplay()
    $('.collapse').on('hidden', =>
      $('#toggle-errors').text(@showMessage)
    )
    $('.collapse').on('shown', =>
      $('#toggle-errors').text(@hideMessage)
    )

  errorHasChanged: ( ->
    @_updateErrorDisplay()
  ).observes('controller.errorMessage')

  _updateErrorDisplay: ->
    $error_button = $('#toggle-errors')
    # When there is no error message on the annual report controller, then
    # the page has not transitioned to a sandbox shipments yet, so all 
    # errors are shown. Well yes, it does sound a bit messy... any ideas?
    if @controller.get('errorMessage').length == 0
      $(".collapse").collapse('show')
      $error_button.text(@hideMessage)
    # The page has transitioned to sandbox_shipments and this will set an 
    # error message on the parent controller. 
    else
      $(".collapse").collapse('hide')
      $error_button.text(@showMessage)

