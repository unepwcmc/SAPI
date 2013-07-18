Species.AppendixDropdownCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  controller: null
  content: []

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    designation: ( ->
      @get('parentView.controller.designation')
    ).property()
    template: Ember.Handlebars.compile('<div class="inactive {{unbound view.designation}}_appendix a_{{unbound this}}">{{this}}</div>')

    touchEnd: (event) ->
      @click(event)

    click: (event) ->
      # The click event fires for list items as well as circles,
      # this is a bit of a hacky method of ignoring list item clicks
      if ($(event.target).not('div').length > 0)
        return

      # Add the selected appendices to the appendices filter array
      # Equivalent to a selectionBinding in a dropdown list
      selectedAppendices = @get('parentView.controller.selectedAppendices')
      if (selectedAppendices.contains(@get('context')))
        selectedAppendices.removeObject(@get('context'))
      else
        selectedAppendices.addObject(@get('context'))

      $(event.target).toggleClass('inactive')
