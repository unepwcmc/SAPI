Species.EventsSearchDropdown = Ember.View.extend
  templateName: 'species/events_search_dropdown'
  classNames: ['popup-clickable', 'popup-holder01']
  placeholder: ( ->
      'Type to filter meetings'
  ).property()
