Species.AutoCompleteTaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  otherMatches: DS.attr("array")

  autoCompleteSuggestion: ( ->
    if @get('otherMatches') != undefined && @get('otherMatches').length > 0
      @get('fullName') + ' (' + @get('otherMatches').join( ', ') + ')'
    else
      @get('fullName')
  ).property('fullName', 'otherMatches')
