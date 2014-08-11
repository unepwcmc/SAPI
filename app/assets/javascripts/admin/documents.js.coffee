$(document).ready ->

  $('#event_id').chained('#event_type')

  $('#event_link').click( (e) ->
    event_id = $('#event_id').val()
    $(e.target).attr('href', 'events/' + event_id + '/documents')
  )
