Species.SingleDropdownComponent = Ember.Component.extend
  layoutName: 'species/components/single-dropdown'

  titleOrSelection: ( ->
    if @get('selection')
      @get('selection.name')
    else
      @get('title')
  ).property('title', 'selection')

  actions:
    handleSelection: (selection) ->
      console.log('hello', selection)
      @sendAction('action', selection)

    handleDeselection: (selection) ->
      console.log('hello', selection)
      @sendAction('clearAction', selection)