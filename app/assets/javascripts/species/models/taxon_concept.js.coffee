Species.TaxonConcept = DS.Model.extend
  #taxonomyName: DS.attr("string")
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  authorYear: DS.attr("string")
  phylumName: DS.attr("string")
  orderName: DS.attr("string")
  className: DS.attr("string")
  familyName: DS.attr("string")
  commonNames: DS.attr("array")
  synonyms: DS.attr("array")
  matchingNames: DS.attr("array")
  subspecies: DS.attr("array")
  distributions: DS.attr("array")
  references: DS.attr("array")
  standardReferences: DS.attr("array")
  citesQuotas: DS.attr("array")
  citesSuspensions: DS.attr("array")
  citesListings: DS.attr("array")
  cmsListings: DS.attr("array")
  cmsInstruments: DS.attr("array")
  euListings: DS.attr("array")
  euDecisions: DS.attr("array")
  distributionReferences: DS.attr("array")
  taxonomy: DS.attr("string")

  searchResultDisplay: ( ->
    baseDisplay = @get('fullName') + ' <span class="author-year">' + @get('authorYear') + '</span>'
    if @get('matchingNames') != undefined && @get('matchingNames').length > 0
      baseDisplay = baseDisplay + ' <span class="synonyms">(' + @get('matchingNames').join(', ') + ')</span>'
    baseDisplay
  ).property('fullName', 'matchingNames', 'authorYear')
