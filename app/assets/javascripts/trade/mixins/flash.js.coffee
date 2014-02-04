Trade.Flash = Ember.Mixin.create
  needs: 'application'
  application: Ember.computed.alias('controllers.application')
  notification: Ember.computed.alias('controllers.application.notification')
  flashSuccess: (options) ->
    @get('application').notify({
      title: "Done"
      message: options.message,
      type: "alert-success",
      persists: options.persists
    })
  flashError: (msg, persists) ->
    @get('application').notify({
      title: "Error"
      message: options.message,
      type: "alert-error",
      persists: options.persists
    })
  flashClear: ->
    @get('application').send('closeNotification')