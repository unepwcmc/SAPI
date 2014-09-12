$(document).ready ->
  $('.show_more a.link').click( (e) ->
    historicRows = $(e.target).parent().prev('table').find('tr')
    if historicRows.hasClass('hidden')
      historicRows.removeClass('hidden')
      $(e.target).text('HIDE HISTORY')
    else
      historicRows.addClass('hidden')
      $(e.target).text('SHOW HISTORY')
  )