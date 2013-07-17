Species.AppendixDropdownCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: []
  selectedAppendices: []

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    template: Ember.Handlebars.compile('<div class="cites_appendix a_{{unbound this}}">{{this}}</div>')

    active: ( ->
      $.inArray(@get('context'), @get('selectedAppendices')) > 0
    ).property()

    touchEnd: (event) ->
      @click(event)

    click: (event) ->
      # The click event fires for list items as well as circles,
      # this is a bit of a hacky method of ignoring list item clicks
      if ($(event.target).not('div').length > 0)
        return

      # Add the selected appendices to the appendices filter array
      # Equivalent to a selectionBinding in a dropdown list
      selectedAppendices = @get('parentView.selectedAppendices')
      if (selectedAppendices.contains(@get('context')))
        selectedAppendices.removeObject(@get('context'))
      else
        selectedAppendices.addObject(@get('context'))

      $(event.target).toggleClass('inactive')
