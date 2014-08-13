$(document).ready ->

  $('#event-id').chained('#event-type')

  $('#event-link').click( (e) ->
    event_id = $('#event-id').val()
    $(e.target).attr('href', 'events/' + event_id + '/document_batch/new')
  )
