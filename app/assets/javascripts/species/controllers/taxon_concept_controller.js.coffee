Species.TaxonConceptController = Ember.ObjectController.extend

  citesListingsExpanded: false

  expandCitesListings: () ->
    this.set('citesListingsExpanded', true)
    $('#cites_listings').
      find('.historic').show('slow')

  contractCitesListings: () ->
    this.set('citesListingsExpanded', false)
    $('#cites_listings').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#cites_listings").offset().top
      , 1000

  citesQuotasExpanded: false

  expandCitesQuotas: () ->
    this.set('citesQuotasExpanded', true)
    $('#cites_quotas').
      find('.historic').show('slow')

  contractCitesQuotas: () ->
    this.set('citesQuotasExpanded', false)
    $('#cites_quotas').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#cites_quotas").offset().top
      , 1000
