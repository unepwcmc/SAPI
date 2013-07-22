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
  subspecies: DS.attr("array")
  mTaxonConcept: DS.attr("array")
  distributions: DS.attr("array")
  references: DS.attr("array")
  standardReferences: DS.attr("array")
  citesQuotas: DS.attr("array")
  citesSuspensions: DS.attr("array")
  citesListings: DS.attr("array")
  euListings: DS.attr("array")
  matchingNames: DS.attr("string")
  distributionReferences: DS.attr("array")

  autoCompleteSuggestion: ( ->
    if @get('synonyms').length > 0
      @get('fullName') + ' (' + @get('synonyms').join( ', ') + ')'
    else
      @get('fullName')
  ).property('fullName', 'synonyms')


Species.TaxonConcept.FIXTURES = [
  id: 2751
  fullName: "Antilocapra americana"
  rankName: "SPECIES"
,
  id: 10887
  fullName: "Antilocapra americana mexicana"
  rankName: "SUBSPECIES"

]
