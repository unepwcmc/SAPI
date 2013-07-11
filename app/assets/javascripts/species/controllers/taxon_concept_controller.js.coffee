Species.TaxonConceptController = Ember.ObjectController.extend

  citesListingsExpanded: false

  expandCitesListings: () ->
    this.set('citesListingsExpanded', true)
    $('#cites_listings').
      find('.historic').show('fast')

  contractCitesListings: () ->
    this.set('citesListingsExpanded', false)
    $('#cites_listings').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#cites_listings").offset().top
      , 500

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

  citesSuspensionsExpanded: false

  expandCitesSuspensions: () ->
    this.set('citesSuspensionsExpanded', true)
    $('#cites_suspensions').
      find('.historic').show('slow')

  contractCitesSuspensions: () ->
    this.set('citesSuspensionsExpanded', false)
    $('#cites_suspensions').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#cites_suspensions").offset().top
      , 1000

  citesSuspensionsEmpty: () ->
    alert("A!")

  euListingsExpanded: false

  expandEuListings: () ->
    this.set('euListingsExpanded', true)
    $('#eu_listings').
      find('.historic').show('slow')

  contractEuListings: () ->
    this.set('euListingsExpanded', false)
    $('#eu_listings').
      find('.historic').hide('slow')
    $("html, body").animate
      scrollTop: $("#eu_listings").offset().top
      , 1000
