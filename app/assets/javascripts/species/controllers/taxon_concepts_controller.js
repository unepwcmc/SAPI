Species.TaxonConceptsController = Ember.ArrayController.extend({
  content: null,
  contentObserver: function(){
    console.log('www')
  }.observes('content.didLoad')
});
