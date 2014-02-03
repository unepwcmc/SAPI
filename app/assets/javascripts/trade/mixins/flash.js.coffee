Trade.Flash = Ember.Mixin.create
  needs: 'application'
  application: Ember.computed.alias('controllers.application')
  notification: Ember.computed.alias('controllers.application.notification')
  flashSuccess: (msg, persists) ->
    @get('application').notify({
      message: msg,
      type: "alert-success",
      persists: persists || false
    })
  flashError: (msg, persists) ->
    @get('application').notify({
      message: msg,
      type: "alert-error",
      persists: persists || false
    })
  flashClear: ->
    @get('application').send('closeNotification')