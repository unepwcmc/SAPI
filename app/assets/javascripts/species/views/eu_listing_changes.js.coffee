Species.EuListingChanges = Ember.View.extend
  templateName: 'species/taxon_concept/eu_listing_changes'

  mouseEnter: (evt) ->
    $("#eu_listings").addClass("hovered")

  mouseLeave: (evt) ->
    $("#eu_listings").removeClass("hovered")

