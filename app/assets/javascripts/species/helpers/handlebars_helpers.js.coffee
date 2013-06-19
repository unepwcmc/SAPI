Ember.Handlebars.helper "foreach", (arr, options) ->
  return options.inverse(this)  if options.inverse and not arr.length
  arr.map((item, index) ->
    item.$index = index
    item.$first = index is 0
    options.fn item
  ).join ""

Ember.Handlebars.helper "eachPart", (arr, options) ->
  return options.inverse(this) if options.inverse and not arr.length
  limit = Math.ceil(arr.length / options.hash.parts)
  offset = options.hash.page * limit
  new_arr = arr.slice(offset, limit+offset)
  new_arr.map((item, index) ->
    options.fn item
  ).join ""
  
Ember.Handlebars.helper "formattedTags", (value, options) ->
  escaped = Handlebars.Utils.escapeExpression(value)
  formatted = escaped.split(',').map((item) ->
  	"<span class=\"tage\">" + item + "</span>"
  ).join ""
  new Handlebars.SafeString(formatted)
