# TASK: when clicking on the higher order taxons in the species results
#  headers, I want to fire a new search.

Species.TaxonConceptLinkView = Ember.View.extend
  templateName: 'species/taxon_concept_link'
  tagName: 'a'
  classNames: ['emb-link']

  click: (e) ->
    params = 
      taxonomy: @get('controller').get('controllers.search').get('taxonomy')
      taxon_concept_query: @get('context').toString()
    @get('controller').get('controllers.search')
      .send('redirectToOpenSearchPage', params)

