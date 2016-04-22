# for some reason cannot use bound helper here
# "registerBoundHelper helpers don't support block usage"
# so using a regular helper
Ember.Handlebars.registerHelper "eachPart", (arr, options) ->
  arr = Ember.Handlebars.get(this, arr, options)
  return options.inverse(this) if options.inverse and not arr.length
  limit = Math.ceil(arr.length / options.hash.parts)
  offset = options.hash.page * limit
  new_arr = arr.slice(offset, limit+offset)
  new_arr.map((item, index) ->
    options.fn item
  ).join ""

Ember.Handlebars.helper "formattedTags", (value, options) ->
  escaped = Handlebars.Utils.escapeExpression(value)
  split = escaped.split(',')
  formatted = if split.length == 1 && split[0] == ''
    ''
  else
    split.map((item) ->
      "<span class=\"tage\">" + item + "</span>"
    ).join ""
  new Handlebars.SafeString(formatted)

Ember.Handlebars.registerHelper('highlight', (suggestion, options) ->
  suggestion = Ember.Handlebars.get(this, suggestion, options)
  query = Ember.Handlebars.get(this, options.hash.query, options)
  return suggestion unless query
  query = query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
  # 'red collared' should highlight 'red-collared'
  queryWithHyphens = query.replace(/\s/, '-')
  transform = ($1, match) ->
    "<span class='match'>" + match + "</span>"
  new Handlebars.SafeString(suggestion.replace(new RegExp("(" + queryWithHyphens + '|' + query + ")", "gi"), transform))
)

Ember.Handlebars.registerHelper 'stringToArray', (string, options) ->
  string = Ember.Handlebars.get(this, string, options)
  array = string.split options.hash.splitter
  array.map((item, index) ->
    options.fn item
  ).join ""

# Given an id, a model and a field, return the field value for that item.
Ember.Handlebars.registerHelper 'getItem', (id, options) ->
  id = Ember.Handlebars.get(this, id, options)
  field = options.hash.field
  model = options.hash.model
  Species[model].find(id).get(field)

Ember.Handlebars.registerHelper 'sizeGt', (str, options) ->
  str = Ember.Handlebars.get(this, str, options)
  if str.length > options.hash.max then options.fn(@) else options.inverse(@)

Ember.Handlebars.registerHelper 'tolower', (str, options) ->
  str = Ember.Handlebars.get(this, str)
  defaultString = options.hash?.default or ""
  if str then str.toLowerCase() else defaultString

Ember.Handlebars.helper 'truncate', (text, options) ->
  limit = options.hash.limit || 60
  if text.length > limit
    text = text.substr(0, limit - 3) + "..."
  return text
