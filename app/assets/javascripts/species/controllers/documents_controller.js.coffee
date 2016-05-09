Species.DocumentsController = Ember.ArrayController.extend Species.SearchContext, Species.DocumentLoader,
  needs: ['elibrarySearch']
  searchContext: 'documents'
