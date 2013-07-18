Species.AppendixButton = Ember.View.extend
  tagName: 'a'
  href: '#'

  classNames: ['link']

  controller: null

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedAppendices = @get('controller.selectedAppendices')
    appendices = @get('controller.appendices')
    if (selectedAppendices.length == 0 || selectedAppendices.length == appendices.length)
      return "APPENDIX"
    else
      return selectedAppendices.sort().join(" & ")
  ).property("controller.selectedAppendices.@each")
