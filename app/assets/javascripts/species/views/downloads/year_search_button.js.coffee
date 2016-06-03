Species.YearSearchButton = Ember.View.extend(Species.SearchFormDropdowns,
  tagName: 'a'
  href: '#'
  classNames: ['link']

  selectedYears: null

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedYears = @get('selectedYears')
    if (selectedYears.length == 0)
      return "YEAR"
    else if (selectedYears.length == 1)
      return "1 YEAR"
    else
      return selectedYears.length + " YEARS"
  ).property("controller.selectedYears.@each")
)
