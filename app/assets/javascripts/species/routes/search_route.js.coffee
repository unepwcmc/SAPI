Species.SearchRoute = Ember.Route.extend
  
  setupController: (controller, model) ->
    @controllerFor('taxonConcepts').set('content', Species.TaxonConcept.find model )

  renderTemplate: ->
    @render "taxonConcepts"

  serialize: (model) ->
    #console.log model
    {params: '?taxonomy=1'}

  #model: (params) ->
  #  console.log 'xxx', params
  #  #Species.TaxonConcept.find params.params