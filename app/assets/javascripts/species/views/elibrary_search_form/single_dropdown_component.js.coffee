Species.SingleDropdownComponent = Ember.Component.extend
  layoutName: 'species/components/single-dropdown'
  classNames: ['popup-area']

  titleOrSelection: ( ->
    if @get('selection')
      @get('selection.name')
    else
      @get('title')
  ).property('title', 'selection')

  actions:
    handleSelection: (selection) ->
      @sendAction('action', selection)
      @.$('.popup-holder01').hide()

    handleDeselection: (selection) ->
      @sendAction('clearAction', selection)