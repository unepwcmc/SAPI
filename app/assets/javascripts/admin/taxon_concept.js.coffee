window.SAPIAdmin ||= {}

class SAPIAdmin.EditableList
  constructor: (options) ->
    @list = options.list || []
    @$el  = $(options.el) || $('<ul>')

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
      # PUT to @url
    else
      options.success.apply(@)

  render: ->
    $list = @$el.empty()

    @list.forEach((item) =>
      $deleteLink = $('<a href="#">')
        .addClass('pull-right')
        .html('<i class="icon-remove">')

      $deleteLink.click(@delete)

      $item = $("<li>")
        .attr('data-id', item.id)
        .append(item.name)
        .append($deleteLink)

      $list.append($item)
    )

    return @$el

$(document).ready ->
  $('.typeahead.geo_entity').typeahead
    source: (query, process) =>
      $.get('/admin/geo_entities/autocomplete',
        name: query
        , (data) =>
          @geoEntitiesMap = _.groupBy(data, 'name')
          names = _.map(data, (e) -> e.name)

          return process(names)
      )

    highlighter: (item) ->
      # Only highlight matches at the start of strings

      query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      transform = ($1, match) ->
        return '<strong>' + match + '</strong>'

      return item.
        replace(new RegExp('^(' + query + ')', 'i'), transform).
        replace(new RegExp('=(' + query + ')', 'ig'), transform)

    updater: (item) =>
      entityObject = @geoEntitiesMap[item][0]
      window.geoEntitiesList.push(entityObject) if entityObject?

      return item

  window.NestedFormEvents::insertFields = (content, assoc, link) ->
    $el = $('<tr>')
    $(content).children().each((i, element) ->
      if $(element).attr('type') != 'hidden'
        $td = $('<td>')
        $td.html(element)
        $el.append($td)
    )

    $('.table tr:last').after($el)
