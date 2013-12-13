Trade.ShipmentsRoute = Ember.Route.extend

  beforeModel: ->
    (new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('geoEntities').load())
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('terms').set('content', Trade.Term.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('units').set('content', Trade.Unit.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('sources').set('content', Trade.Source.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(@controllerFor('purposes').set('content', Trade.Purpose.find()))
    )).then(new Ember.RSVP.Promise((resolve) =>
      resolve(Ember.run.sync())
    ))

  model: (params, queryParams, transition) ->
    queryParams.page = 1 unless queryParams.page
    Trade.Shipment.find(queryParams)
