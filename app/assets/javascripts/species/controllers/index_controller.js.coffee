Species.IndexController = Ember.Controller.extend
  content: null

  loadResults: ->
    @transitionToRoute('results')