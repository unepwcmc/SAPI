Species.TaxonConceptRoute = Ember.Route.extend
  model: (params) ->
    Species.TaxonConcept.find(params.taxon_concept_id)

  setupController: (controller, model) ->
    # Call _super for default behavior (as of rc4)
    this._super(controller, model)
    # If the route is reached using a {{#linkTo route myObject}} or
    # transitionTo(myObject) call then the passed object is used to call
    # setupController directly and model is not called.
    # We might need to revisit this when loading particular tabs.
    model.reload() if model.get('citesListings') == undefined

  #redirect: () ->
  #  @transitionTo('taxon_concept.legal')
