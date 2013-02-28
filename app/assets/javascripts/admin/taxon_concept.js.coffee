$(document).ready ->
  $(".tags").select2()

  $('.typeahead.geo_entities').typeahead
    source: (query, process) ->
      $.get('/admin/geo_entities/autocomplete',
        name: query
      , (data) =>
        names = _.map(data, (c) -> c.name)
        return process(names)
      )

  $('textarea.annotation')
    .focus(-> $(@).animate(height: "15em", 500))
    .blur(-> $(@).animate(height: "4em", 500))
