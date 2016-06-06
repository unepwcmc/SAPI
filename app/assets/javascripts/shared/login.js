$(document).ready(function(){

  $('.alert .close').on('click', function(e) {
    $(this).parent().remove();
  });

  $('#login_form form').submit( function(e) {
    e.preventDefault();
    var form = this;
    $.ajax({
      url: '/users/sign_in',
      type: 'POST',
      dataType: 'json',
      data: {
        user: {
          email: $(form).find('#user_email').val(),
          password: $(form).find('#user_password').val(),
          remember_me: $(form).find('#user_remember_me:checked').length
        }
      },
      success: function(data) {
        location.href = '/'
      },
      error: function(xhr, ajaxOptions, thrownError) {
        var error = "<div class='error-box'><p class='error-message'>" +
          xhr.responseText + "</p></div>"
        $('.login-header').addClass('less-margin');
        $('.error-box').remove()
        $('.login-error').append(error)
      }
    });
  });

  $('.logged-header-container .right').on('click', function(e){
    e.preventDefault();
    $('.logged-header-dropdown').toggle();
    var icon = $(this).find('i.dropdown');
    toggleCaretIcon(icon);
  });

  $('.logged-header-dropdown .fa-times').on('click', function(e) {
    e.preventDefault();
    var icon = $('.logged-header').find('i.dropdown');
    toggleCaretIcon(icon);
    $('.logged-header-dropdown').hide();
  });

  function toggleCaretIcon(icon){
    if(icon.hasClass("fa-caret-down")){
      icon.removeClass("fa-caret-down").addClass("fa-caret-up");
    }
    else {
      icon.removeClass("fa-caret-up").addClass("fa-caret-down");
    }
  }

});
