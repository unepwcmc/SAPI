$(document).ready ->
  $('.suspension.select2').select2()

  $(".suspension.datepicker").datepicker(
    format: "dd/mm/yyyy",
    autoclose: true
  )
