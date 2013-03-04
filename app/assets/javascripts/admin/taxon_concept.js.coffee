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
