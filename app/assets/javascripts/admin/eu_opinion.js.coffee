$(document).ready ->
  $('.eu_opinion.select2').select2()

  $(".eu_opinion.datepicker").datepicker(
    format: "dd/mm/yyyy",
    autoclose: true
  )
