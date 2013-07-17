Species.AppendixButton = Ember.View.extend
  tagName: 'a'
  href: '#'

  classNames: ['link']

  template: Ember.Handlebars.compile("{{view.summary}}"),

  summary: ( ->
    selectedAppendices = @get('content')
    appendices = @get('appendices')
    if (selectedAppendices.length == 0 || selectedAppendices.length == appendices.length)
      return "APPENDIX"
    else
      return selectedAppendices.sort().join(" &amp; ")
  ).property("content.@each")
