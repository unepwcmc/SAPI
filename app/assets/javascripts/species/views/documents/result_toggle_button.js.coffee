Species.ResultToggleButton = Ember.View.extend
  tagName: 'i'
  classNames: ['fa', 'fa-plus-circle']

  click: (event) ->
    element = event.target
    @toggleIcon(element)
    table = $(element).closest('tr').next('tr.table-row')
    table.slideToggle("slow")
    table.find('div.inner-table-container').slideToggle("slow")
    table.find('table').DataTable({
        "bPaginate": false,
        "bLengthChange": false,
        "bFilter": false,
        "bInfo": false,
        "sScrollY": "400px",
        "scrollCollapse": true,
        "bDestroy": true,
        "aoColumns": [
          null,
          null,
          null,
          {"bSortable": false},
          {"bSortable": false},
          {"bSortable": false},
          {"bSortable": false}
        ]
    });

  toggleIcon: (icon) ->
    if $(icon).hasClass("fa-plus-circle")
      $(icon).removeClass("fa-plus-circle").addClass("fa-minus-circle")
    else
      $(icon).removeClass("fa-minus-circle").addClass("fa-plus-circle")

  
