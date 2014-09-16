Trade.Router.map (match)->
  @resource 'annual_report_uploads'
  @resource 'annual_report_upload', { path: 'annual_report_uploads/:annual_report_upload_id' }, ->
    @resource 'sandbox_shipments'
  @resource 'validation_rules'
  @resource 'search', { path: 'search' }, ->
    @route 'results'
  @route('promise');

Trade.PromiseRoute = Ember.Route.extend
  model: () ->
    new Ember.RSVP.Promise((resolve) ->
      Ember.run.later(() ->
        resolve()
      , 100)
    )

Trade.LoadingRoute = Ember.Route.extend()

Trade.BeforeRoute = Ember.Route.extend
  # close any open notifications before a route loads
  activate: ->
    @controllerFor('application').send('closeNotification')
