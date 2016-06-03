Species.SearchFormDropdowns = Ember.Mixin.create

  handlePopupClick: (event) ->
    event.stopPropagation()
    selected_popup = @.$().parent().find('.popup-clickable')
    selected_popup.toggle()
    $('.popup-clickable').not(selected_popup).hide()

  click: (event) ->
    @handlePopupClick(event)

