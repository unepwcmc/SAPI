
Species.IndexController = Ember.Controller.extend
  
  content: null
  taxonomy: 'cites_eu'
  scientificName: null
  selectedLocation: null


  loadTaxonConcepts: ->
    q = Ember.Object.create
      taxonomy: @taxonomy
      scientificName: @scientificName
      selectedLocation: @selectedLocation

    params = Ember.Object.create
      id: "?location=1&taxonomy=2"

    @transitionToRoute('search', {taxonomy: 1})
