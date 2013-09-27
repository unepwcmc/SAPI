Species.HigherTaxaCitesEuController = Ember.ArrayController.extend
  content: null
  contentByRank: null
  loaded: false

  contentObserver: ( ->
    @set('loaded', true)
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

  load: ->
    unless @get('loaded')
      @set('content', 
        Species.AutoCompleteTaxonConcept.find({
          taxonomy: 'cites_eu'
          ranks: ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
          per_page: 1000
        })
      )