Species.HigherTaxaSearchButton = Ember.View.extend(Species.SearchFormDropdowns,
  tagName: 'a'
  href: '#'
  classNames: ['link']

  controller: null

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedTaxonConcepts = @get('controller.selectedTaxonConcepts')
    if (selectedTaxonConcepts.length == 1)
      return "1 TAXON"
    else
      return "TAXON"
  ).property("controller.selectedTaxonConcepts.@each")
)
