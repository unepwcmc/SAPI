Species.SingleDropdownComponent = Ember.Component.extend
  layoutName: 'species/components/single-dropdown'
  classNames: ['popup-area']

  placeholderOrSelection: ( ->
    if @get('selection')
      @get('selection.name')
    else
      @get('placeholder')
  ).property('selection')

  actions:
    handleSelection: (selection) ->
      @sendAction('action', selection)

    handleDeselection: (selection) ->
      @sendAction('clearAction', selection)
