Species.ResultToggleButton = Ember.View.extend
  tagName: 'i'
  classNames: ['fa', 'fa-plus-circle']

  click: (event) ->
    element = event.target
    @toggleIcon(element)
    table = $(element).closest('tr').nextAll('.table-row')[0]
    $(table).slideToggle("slow")
    $(table).find('div.inner-table-container').slideToggle("slow")

  toggleIcon: (icon) ->
    if $(icon).hasClass("fa-plus-circle")
      $(icon).removeClass("fa-plus-circle").addClass("fa-minus-circle")
    else
      $(icon).removeClass("fa-minus-circle").addClass("fa-plus-circle")
