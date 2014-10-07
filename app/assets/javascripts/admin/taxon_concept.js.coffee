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

  $('.select2').select2()

  $(".datepicker").datepicker(
    format: "dd/mm/yyyy",
    autoclose: true
  )

  $('#taxon_concept_internal_notes_popover_link').popover(
    container: 'body'
    content: $('#taxon_concept_internal_notes_popover').html(),
    template: '<div class="popover" style="max-width:800px"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
  )
