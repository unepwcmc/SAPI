Species.HigherTaxaCitesEuController = Ember.ArrayController.extend
  content: null
  contentByRank: null

  contentObserver: ( ->
    Ember.run.once(@, 'groupHigherTaxaByRank')
  ).observes("content.@each.didLoad")

  groupHigherTaxaByRank: ->
    @set('contentByRank', 
      ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY'].map((e) =>
        {
          rankName: e
          taxonConcepts: @get('content').filterProperty('rankName', e)
        }
      ).filter((e) ->
        e.taxonConcepts.length > 0
      )
    )
