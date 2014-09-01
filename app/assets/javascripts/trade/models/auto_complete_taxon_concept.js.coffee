Trade.AutoCompleteTaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  nameStatus: DS.attr("string")
  matchingNames: DS.attr("array")

  autoCompleteSuggestion: ( ->
    nameStatusFormatted = unless @get('nameStatus') == 'A'
      ' [' + @get('nameStatus') + ']'
    else
      ''
    if @get('matchingNames') != undefined && @get('matchingNames').length > 0
      @get('fullName') + nameStatusFormatted + ' (' + @get('matchingNames').join( ', ') + ')'
    else
      @get('fullName') + nameStatusFormatted
  ).property('fullName', 'matchingNames')
