Species.TaxonConceptsRoute = Ember.Route.extend
  
  setupController: (controller, model) ->
    @controllerFor('index').set('model', model)


  serialize: (model) ->
    console.log "serialize", model
    x = {params: model.get "id"}
    #console.log x
    x

  #model: (params) ->
  #  console.log 'xxx', params
  #  Species.TaxonConcept.find()

