$(document).ready(function() {

  $('.code').editable({
    validate: function(value) {
      if($.trim(value) == '') return 'This field is required';
    },
    placement: 'right'
  });
  $('.name').editable({
    validate: function(value) {
      if($.trim(value) == '') return 'This field is required';
    },
    placement: 'right'
  });
  $('.description').editable({
    placement: 'right'
  });

});
