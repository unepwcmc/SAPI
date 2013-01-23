window.SAPIAdmin ||= {}

class SAPIAdmin.EditableList
  constructor: (options) ->
    @list = options.list || []
    @$el  = $(options.el) || $('<ul>')
    @showEditLink = options.showEditLink || false
    @edit = options.onEdit || @edit

    @url = options.url if options.url?

  push: (item) ->
    # Look for items with the same name, rather than checking for object
    # equality, as objects will not necessarily be equal despite having
    # the same values
    unless _.where(@list, name: item.name).length > 0
      @list.push(item)

      @update(
        success: @render
      )

  edit: (e) =>

  delete: (e) =>
    e.preventDefault()
    e.stopPropagation()

    name = $(e.target).parents('li').text()

    entityObject = _.first(_.where(@list, name: name))
    entityObjectIndex = @list.indexOf(entityObject)
    @list.splice(entityObjectIndex, 1)

    @update(
      success: @render
    )

  update: (options) ->
    if @url?
      $.ajax(
        url: @url
        type: options.type || 'PUT'
        success: options.success
        error: options.error
      )
    else
      options.success.apply(@)

  render: ->
    $list = @$el.empty()

    @list.forEach((item) =>
      $deleteLink = $('<a href="#">')
        .addClass('pull-right')
        .html('<i class="icon-remove">')

      $deleteLink.click(@delete)

      if @showEditLink
        $editLink = $('<a href="#">')
          .addClass('pull-right')
          .html('<i class="icon-edit">')

        $editLink.click(@edit)

      $item = $("<li>")
        .attr('data-id', item.id)
        .append(item.name)
        .append($deleteLink)
        .append($editLink || '')

      $list.append($item)
    )

    return @$el

$(document).ready ->
  window.NestedFormEvents::insertFields = (content, assoc, link) ->
    $el = $('<tr>')
    $(content).children().each((i, element) ->
      if $(element).attr('type') != 'hidden'
        $td = $('<td>')
        $td.html(element)
        $el.append($td)
    )

    $('.table tr:last').after($el)
