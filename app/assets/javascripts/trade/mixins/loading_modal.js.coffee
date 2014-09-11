Trade.LoadingModal = Ember.Mixin.create

  showLoadingModal: ->
    $('#loading-modal').modal('show')

  hideLoadingModal: ->
    $('#loading-modal').modal('hide')
