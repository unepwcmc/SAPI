Species.IndexController = Ember.Controller.extend
  content: null
  taxonomy: 'cites_eu'
  scientificName: null

  loadTaxonConcepts: ->
    console.log(@get('taxonomy'))
    console.log(@get('scientificName'))
    @transitionToRoute('taxon_concepts')