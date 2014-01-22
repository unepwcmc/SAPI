Trade.ValidationErrorsView = Ember.CollectionView.extend
  content: null
  classNames: ['collapse']
  itemViewClass: Ember.View.extend
    templateName: 'trade/validation_error'
  emptyView: Ember.View.extend
    template: Ember.Handlebars.compile("No results")

  didInsertElement: ->
    $('.collapse').on('hidden', ->
      $('#toggle-errors').text('Show errors')
    )

    $('.collapse').on('shown', ->
      $('#toggle-errors').text('Hide errors')
    )
