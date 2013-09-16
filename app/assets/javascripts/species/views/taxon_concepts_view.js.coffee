Species.TaxonConceptsView = Ember.View.extend
  templateName: 'species/taxon_concepts'
  didInsertElement: () ->
    $('body').addClass('inner')

  actions:
    nextPage: ->
      @controller.transitionToPage yes

    prevPage: ->
      @controller.transitionToPage no
