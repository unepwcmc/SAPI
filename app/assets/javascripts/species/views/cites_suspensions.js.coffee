Species.CitesSuspensions = Ember.View.extend
  templateName: 'species/taxon_concept/cites_suspensions'

  mouseEnter: (evt) ->
    $("#cites_suspensions").addClass("hovered")

  mouseLeave: (evt) ->
    $("#cites_suspensions").removeClass("hovered")

