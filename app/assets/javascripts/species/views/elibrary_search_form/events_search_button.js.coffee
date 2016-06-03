Species.EventsSearchButton = Ember.View.extend Species.MultipleSelectionSearchButton, Species.SearchFormDropdowns,

  summary: ( ->
    short = (@get('shortPlaceholder') == true)
    if (@get('selectedEvents'))
      if (@get('selectedEvents').length == 0)
        if short
          "MEETINGS"
        else
          "All meetings"
      else if (@get('selectedEvents').length == 1)
        if short
          "1 MEET"
        else
         "1 meeting"
      else
        if short
          @get('selectedEvents').length + " MEETS"
        else
          @get('selectedEvents').length + " meetings"
    else
      "MEETINGS"
  ).property("selectedEvents.@each")
