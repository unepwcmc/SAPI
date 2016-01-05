Species.DocumentsController = Ember.ObjectController.extend Species.SearchContext, Species.DocumentLoader,
  needs: ['elibrarySearch']
  searchContext: 'documents'
