$(document).ready ->
  event_type = $('#event_type')
  event = $('#event')
  event_link = $('#event_link')

  event_type.prop('selectedIndex',0)

  event_type.change( () ->
    event_type = $(@).val()
    if (event_type)
      event.attr('disabled', false)
      $.getJSON(event_type+'.json', ( data ) ->
        items = ['<option value="" disabled selected>Select your option</option>']
        $.each(data, ( idx, obj ) ->
          items.push(
            "<option value='" + obj.value + "'>" + obj.text + "</option>"
          )
        )
        event.html(items.join( "" ))
      )
    else
      event.attr('disabled', true)
      event_link.css('visibility', 'hidden')
  )

  event.change( () ->
    event = $(@).val()
    if (event)
      event_link.attr('disabled', false)
      event_link.css('visibility', 'visible')
      event_link.attr('href', 'events/'+event+'/documents')
    else
      event_link.css('visibility', 'hidden')
  )