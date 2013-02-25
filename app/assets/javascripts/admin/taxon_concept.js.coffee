$(document).ready ->
  $(".tags").select2()

  $('a[data-toggle="popover"]').popover(html: true, placement: 'bottom')

  $('.typeahead.geo_entities').typeahead
    source: (query, process) ->
      $.get('/admin/geo_entities/autocomplete',
        name: query
      , (data) =>
        names = _.map(data, (c) -> c.name)
        return process(names)
      )
