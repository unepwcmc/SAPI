Species.AutoCompleteTaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  otherSearchMatches: DS.attr("array")

  autoCompleteSuggestion: ( ->
    if @get('otherSearchMatches') != undefined && @get('otherSearchMatches').length > 0
      @get('fullName') + ' (' + @get('otherSearchMatches').join( ', ') + ')'
    else
      @get('fullName')
  ).property('fullName', 'otherSearchMatches')
