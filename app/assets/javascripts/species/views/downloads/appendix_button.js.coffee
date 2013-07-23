Species.AppendixButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']

  selectedAppendices: null
  appendices: null

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedAppendices = @get('selectedAppendices')
    appendices = @get('appendices')
    if (selectedAppendices.length == 0 || selectedAppendices.length == appendices.length)
      return "APPENDIX"
    else
      return selectedAppendices.sort().join(" & ")
  ).property("selectedAppendices.@each")
