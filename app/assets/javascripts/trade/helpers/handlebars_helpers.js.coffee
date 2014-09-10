Ember.Handlebars.registerHelper('highlight', (suggestion, options) ->
  suggestion = Ember.Handlebars.get(this, suggestion, options)
  query = Ember.Handlebars.get(this, options.hash.query, options)
  return suggestion unless query
  query = query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
  transform = ($1, match) ->
    "<span class='match'>" + match + "</span>"
  new Handlebars.SafeString(suggestion.replace(new RegExp("(" + query + ")", "gi"), transform))
)

Ember.Handlebars.helper('dataHead', (columns) ->
  data = []
  for column in columns
    name = column.split('.')[0]
      # insert a space before all caps
      .replace(/([A-Z])|_/g, ' $1')
      # uppercase the first character
      .replace(/^./, (str) -> str.toUpperCase() )
    data.push name
  data = '<th>' + data.join("</th><th>") + '</th>'
  new Handlebars.SafeString(data)
)
