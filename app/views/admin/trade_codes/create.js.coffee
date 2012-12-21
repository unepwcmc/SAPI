$('.modal').modal('hide')
$('#admin-in-place-editor table').html("<%= escape_javascript(render('admin/trade_codes/list')) %>")
window.adminInPlaceEditor.init()
window.adminInPlaceEditor.alertSuccess("Operation successful")

