Species.TaxonConceptsView = Ember.View.extend
  templateName: 'species/taxon_concepts'
  didInsertElement: () ->
    $('body').addClass('inner')
    $(".search-block").addClass("search-results")
