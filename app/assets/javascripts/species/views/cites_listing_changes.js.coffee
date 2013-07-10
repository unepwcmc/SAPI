Species.CitesListingChanges = Ember.View.extend
  templateName: 'species/taxon_concept/cites_listing_changes'

  mouseEnter: (evt) ->
    $("#cites_listings").addClass("hovered")

  mouseLeave: (evt) ->
    $("#cites_listings").removeClass("hovered")
