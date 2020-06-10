Species.TaxonConcept = DS.Model.extend
  #taxonomyName: DS.attr("string")
  parentId: DS.attr("number")
  speciesName: DS.attr("string")
  genusName: DS.attr("string")
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
  srgHistory: DS.attr("array")
  distributionReferences: DS.attr("array")
  taxonomy: DS.attr("string")
  nomenclatureNoteEn: DS.attr("string")
  nomenclatureNoteFr: DS.attr("string")
  nomenclatureNoteEs: DS.attr("string")
  nomenclatureNotification: DS.attr("boolean")

  matchingNamesForDisplay: ( ->
    if @get('matchingNames') != undefined && @get('matchingNames').length > 0
      '(' + @get('matchingNames').join(', ') + ')'
    else
      ''
  ).property('matchingNames')

  currentSubspeciesTooltipText: ( ->
    unless @get('subspecies').length > 0 then return no
    designationInfo = if @get('taxonomy') == 'cms'
      " in CMS or the related Agreements"
    else
      " in either the CITES Appendices or the EU Wildlife Trade Regulations"
    "Subspecies pages are only included within Species+ where the subspecies is or was historically listed in its own right" +
    designationInfo +
    ". Where there are no subspecies listed, this indicates that that the legal information that applies to the species applies to all subspecies equally."
  ).property('taxonomy', 'subspecies')

  speciesFullName: ( ->
    if @get('genusName') != null
      @get('genusName') + ' ' + @get('speciesName').toLowerCase()
  ).property('genusName', 'speciesName')
