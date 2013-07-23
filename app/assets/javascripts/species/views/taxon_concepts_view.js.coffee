Species.TaxonConceptsView = Ember.View.extend
  templateName: 'species/taxon_concepts'
  didInsertElement: () ->
    $('body').addClass('inner')
