class window.DistributionReferences
  constructor: (options = {}) ->
    @references ||= {}
    @el = $(options.el) || $('body')

  add: (id, title) ->
    @references[title] = id unless @references[title]?
    @render()

  remove: (value) ->
    if _.isNumber(value)
      _.forEach(@references, (v, key) => delete @references[key] if v == value)
    else
      @references = _.omit(@references, value)

    @render()

  removeAll: ->
    @references = {}
    @render()

  titles: ->
    _.keys(@references)

  toString: ->
    return _.values(@references).join(",")

  render: ->
    template = _.template("""
      <% _.each(references, function(v, key) { %>
        <li>
          <a href="#" class="reference_delete" data-title="<%= key %>"><i class="icon-trash"></i></a>
          <%= key %>
        </li>
      <% }); %>
    """, {references: @references})

    @el.html(template)

    $('.reference_delete').click( (e) =>
      target = $(e.target).parent()
      @remove(target.data('title'))
    )
