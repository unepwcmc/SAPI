Species.TaxonConceptLinkView = Ember.View.extend
  templateName: 'species/taxon_concept_link'
  tagName: 'a'
  classNames: ['emb-link']

  click: (event) ->
    q = $(event.target).text()
    @get('controller').send('newTaxonSearch', q)