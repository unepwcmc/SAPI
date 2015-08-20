Species.DocumentTagLoader = Ember.Mixin.create
  ensureDocumentTagsLoaded: (searchController) ->
    if @controllerFor('documentTags').get('loaded')
      searchController.initDocumentTagsSelectors()
    else
      @controllerFor('documentTags').load()
