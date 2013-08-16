Species.TaxonConceptLegalView = Ember.View.extend
  templateName: 'species/taxon_concept/legal'
  didInsertElement: () ->
    $('body').addClass('inner')
