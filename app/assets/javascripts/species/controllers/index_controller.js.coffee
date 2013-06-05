Species.IndexController = Ember.Controller.extend
  content: null

  loadTaxonConcepts: ->
    @transitionToRoute('taxon_concepts')