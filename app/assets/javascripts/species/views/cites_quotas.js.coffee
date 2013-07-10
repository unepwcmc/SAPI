Species.CitesQuotas = Ember.View.extend
  templateName: 'species/taxon_concept/cites_quotas'

  mouseEnter: (evt) ->
    $("#cites_quotas").addClass("hovered")

  mouseLeave: (evt) ->
    $("#cites_quotas").removeClass("hovered")

