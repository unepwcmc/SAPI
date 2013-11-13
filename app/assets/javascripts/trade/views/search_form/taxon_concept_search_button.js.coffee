Trade.TaxonConceptsSearchButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']
  selectedValues: null
  selectedValuesCollectionName: 'options'
  selectedValueDisplayProperty: 'name'

  template: Ember.Handlebars.compile("{{view.summary}}")

  summary: ( ->
    if (@get('selectedValues').length == 0)
      return ""
    else if (@get('selectedValues').length == 1)
      return @get('selectedValues')[0].get(
        @get('selectedValueDisplayProperty')
      )
    else
      return @get('selectedValues').length + " " +
      @get('selectedValuesCollectionName') + " selected"
  ).property("selectedValues.@each")
