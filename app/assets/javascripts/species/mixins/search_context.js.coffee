Species.SearchContext = Ember.Mixin.create({

  isSearchContextDocuments: ( ->
    @get('searchContext') == 'documents'
  ).property('searchContext')

  isSearchContextSpecies: ( ->
    !@get('isSearchContextDocuments')
  ).property('isSearchContextDocuments')
})
