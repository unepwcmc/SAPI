Trade.PermitController = Ember.Controller.extend
  #needs: ['shipments']
  permitQuery: null

  autoCompletePermits: ( ->
    console.log 'ooooooooooooooooooooooooooooooooooooooo'
    PermitQuery = @get('permitQuery')
    if !permitQuery || permitQuery.length < 3
      return;

    Trade.AutoCompletePermit.find(
      name: @get('name')
      autocomplete: true
    )
  ).property('permitQuery')