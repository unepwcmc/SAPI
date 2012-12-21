$('.modal').modal('hide')
$('#admin-in-place-editor').html("<%= escape_javascript(render('list')) %>")
window.adminInPlaceEditor.init()
window.adminInPlaceEditor.alertSuccess("Operation successful")

