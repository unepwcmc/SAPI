Species.TaxonConceptsController = Ember.ArrayController.extend({
  content: null,
  contentObserver: function(){
    console.log(this.get('content.meta'))
  }.observes('content.didLoad')
});
