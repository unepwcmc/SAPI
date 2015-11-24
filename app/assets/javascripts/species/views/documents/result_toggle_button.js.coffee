Species.ResultToggleButton = Ember.View.extend
  tagName: 'i'
  classNames: ['fa', 'fa-plus-circle']

  click: (event) ->
    element = event.target
    $(element).toggleClass("fa-plus-circle fa-minus-circle")
    table = $(element).closest('tr').next('.table-row')
    $(table).slideToggle("slow")
    $(table).find('div.inner-table-container').slideToggle("slow")
