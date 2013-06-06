Species.TaxonConcept = DS.Model.extend
  #taxonomyName: DS.attr("string")
  rankName: DS.attr("string")
  fullName: DS.attr("string")

  #didLoad: ->
  #  console.log 'ffffffffffffffffff'



Species.TaxonConcept.FIXTURES = [
  id: 2751
  fullName: "Antilocapra americana"
  rankName: "SPECIES"
,
  id: 10887
  fullName: "Antilocapra americana mexicana"
  rankName: "SUBSPECIES"

]