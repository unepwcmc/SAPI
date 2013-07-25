# TASK: when clicking on the higher order taxons in the species results
#  headers, I want to fire a new search.
#
# This view has an atomic template, that contains the name of the taxon 
#  clicked in the results heading. When clicked,
#  `newTaxonSearch` is called on the `TaxonConceptsController`, that will then
#  reset the `taxonConceptQuery` property on the `SearchController` and fire 
#  a new call to `loadTaxonConcepts`.

Species.TaxonConceptLinkView = Ember.View.extend
  templateName: 'species/taxon_concept_link'
  tagName: 'a'
  classNames: ['emb-link']

  click: (event) ->
    q = $(event.target).text()
    @get('controller').send('newTaxonSearch', q)
