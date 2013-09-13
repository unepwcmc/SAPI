Species.TaxonConceptView = Ember.View.extend
  templateName: 'species/taxon_concept'

  didInsertElement: () ->
    $('.search-block').addClass('add')
