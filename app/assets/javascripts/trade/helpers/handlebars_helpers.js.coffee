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
      .replace(/([A-Z])/g, ' $1')
      # uppercase the first character
      .replace(/^./, (str) -> str.toUpperCase() )
    data.push name
  data = '<th>' + data.join("</th><th>") + '</th>'
  new Handlebars.SafeString(data)
)

Ember.Handlebars.helper('dataRow', (columns, codeMappings) ->
  # TODO: the way the titles are added to the markup does not look nice,
  # maybe a more explicit config object?
  data = []
  for column in columns
    split = column.split('.')
    if split?[1] and codeMappings[split[1]]
      data.push(
        "<td><span class='t' title='#{@get(split[0]+'.'+codeMappings[split[1]])}'>#{@get(column)}</span></td>"
      )
    else
      data.push "<td><span class='t' title='#{@get(column)}'>#{@get(column)}</span></td>"
  data = data.join("")
  new Handlebars.SafeString(data)
)