$(document).ready ->
  $(".tags").select2()

  $('textarea.annotation')
    .focus(-> $(@).animate(height: "15em", 500))
    .blur(-> $(@).animate(height: "4em", 500))

  $('.select2').select2({
    placeholder: "Choose an option",
    allowClear: true
  })

  $(".datepicker").datepicker(
    format: "dd/mm/yyyy",
    autoclose: true
  )

  $('#taxon_concept_internal_notes_popover_link').popover(
    container: 'body'
    content: $('#taxon_concept_internal_notes_popover').html(),
    template: '<div class="popover" style="max-width:800px"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
  )
