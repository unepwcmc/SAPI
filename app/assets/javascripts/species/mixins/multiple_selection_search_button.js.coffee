Species.MultipleSelectionSearchButton = Ember.Mixin.create
  loading: ( ->
    "loading" unless @get('loaded')
  ).property('loaded').volatile()

  template: Ember.Handlebars.compile("{{view.summary}}"),

  click: (event, controller) ->
    if @get('controller.isSearchContextDocuments') &&
    @get('taxonConceptQuery') != @get('taxonConceptQueryLastCheck')
      @set('taxonConceptQueryLastCheck', @get('taxonConceptQuery'))
      if @get('taxonConceptQuery.length') >= 3
        query = @get('taxonConceptQuery')
      # we're in the E-Library search, need to check if
      # filtering by taxon is required for locations
      @get(controller).reload(query)
    @handlePopupClick(event)
