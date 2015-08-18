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
      @sendAction('action', selection)

    handleDeselection: (selection) ->
      @sendAction('clearAction', selection)