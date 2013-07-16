Species.DownloadsController = Ember.Controller.extend
  downloadsPopupVisible: false
  downloadsTopButtonVisible: ( ->
    # hide if we're currently showing index
    this.target.get('_activeViews').index == undefined
  ).property()
