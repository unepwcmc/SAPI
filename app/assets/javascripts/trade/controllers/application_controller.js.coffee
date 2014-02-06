Trade.ApplicationController = Ember.Controller.extend
      
  # notification alert
  # type can be: error, info, success
  # example: @get('controllers.application').notify({title: "Error!", message: "An error occurred in foobar.", type: "alert-error"})
  #
  notify: (options) ->
    # do not display message in loading route, wait until any loading is done.
    routeName = this.get('routeName')
    if (routeName != "loading")
      @set('notification', options)
    

  actions:
    # close notification alert
    # bind to action in template, example: {{action "closeNotification"}}
    # detects if persists and closes on next transition
    #
    closeNotification: ->
      notification = @get('notification')
      if notification
        if notification.persists
          notification.persists = null
        else
          @set('notification', null)