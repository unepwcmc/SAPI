Trade.IndexRoute = Ember.Route.extend
  beforeModel: () ->
    @transitionTo('shipments');
