Trade.IndexRoute = Trade.BeforeRoute.extend
  beforeModel: () ->
    @transitionTo('shipments');
