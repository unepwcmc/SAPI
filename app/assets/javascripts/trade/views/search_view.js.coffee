Trade.SearchView = Ember.View.extend
  templateName: 'trade/search'

  didInsertElement: ->
    @.$().delegate('.btn, .action-link', 'click', (e) ->
      $('.popup-holder01').hide()
    )
