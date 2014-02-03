Trade.Flash = Ember.Mixin.create
  needs: 'application'
  application: Ember.computed.alias('controllers.application')
  flashSuccess: (msg, persists) ->
    @get('application').notify({
      title: "Success",
      message: msg,
      type: "alert-success",
      persists: persists || false
    })
  flashError: (msg, persists) ->
    @get('application').notify({
      title: "Error",
      message: msg,
      type: "alert-error",
      persists: persists || false
    })
  flashClear: ->
    @get('application').send('closeNotification')