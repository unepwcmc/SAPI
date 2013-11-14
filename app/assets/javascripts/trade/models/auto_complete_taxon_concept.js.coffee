Trade.AutoCompleteTaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  synonyms: DS.attr("array")

  autoCompleteSuggestion: ( ->
    if @get('synonyms') != undefined && @get('synonyms').length > 0
      @get('fullName') + ' (' + @get('synonyms').join( ', ') + ')'
    else
      @get('fullName')
  ).property('fullName', 'synonyms')
