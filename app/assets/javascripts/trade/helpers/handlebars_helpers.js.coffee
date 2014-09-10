Ember.Handlebars.registerHelper('highlight', (suggestion, options) ->
  suggestion = Ember.Handlebars.get(this, suggestion, options)
  query = Ember.Handlebars.get(this, options.hash.query, options)
  return suggestion unless query
  query = query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
  transform = ($1, match) ->
    "<span class='match'>" + match + "</span>"
  new Handlebars.SafeString(suggestion.replace(new RegExp("(" + query + ")", "gi"), transform))
)
