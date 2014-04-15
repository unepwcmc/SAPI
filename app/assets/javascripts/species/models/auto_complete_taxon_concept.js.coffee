Species.AutoCompleteTaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  matchingNames: DS.attr("array")
  acceptedSubspecies: DS.attr("boolean")

  autoCompleteSuggestion: ( ->
    if @get('matchingNames') != undefined && @get('matchingNames').length > 0
      @get('fullName') + ' (' + @get('matchingNames').join( ', ') + ')'
    else
      @get('fullName')
  ).property('fullName', 'matchingNames')
