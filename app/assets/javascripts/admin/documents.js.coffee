$(document).ready ->

  $('#event').chained('#event_type')

  $('#event_link').click( (e) ->
    event_id = $('#event').val()
    console.log(event_id, e.target)
    $(e.target).attr('href', 'events/' + event_id + '/documents')
  )
