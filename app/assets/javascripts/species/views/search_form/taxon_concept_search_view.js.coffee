Species.TaxonConceptSearchView = Em.View.extend
  templateName: 'species/taxon_concept_search'
  classNames: ['search-form']
  mousedOver: false

  mouseEnter: (event) ->
    @set('mousedOver', true)

  mouseLeave: (event) ->
    @set('mousedOver', false)