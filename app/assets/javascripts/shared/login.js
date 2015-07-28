$(document).ready(function(){

  $('.species-connect').on('click', function(e){
    e.preventDefault();
    $('.species-login-form').slideToggle("slow");
    var icon = $(this).find('i');
    toggleCaretIcon(icon);
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
