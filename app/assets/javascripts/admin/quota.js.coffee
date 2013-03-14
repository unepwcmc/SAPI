$(document).ready ->
  $('.quota.select2').select2()

  $(".quota.datepicker").datepicker(
    format: "dd/mm/yyyy",
    autoclose: true
  )
