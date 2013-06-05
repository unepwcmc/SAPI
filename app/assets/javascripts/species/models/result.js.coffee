Species.Result = DS.Model.extend(
  taxonomyName: DS.attr("string")
  rankName: DS.attr("string")
  fullName: DS.attr("string")
)

Species.Result.FIXTURES = [
  id: 462
  taxonomyName: "CITES_EU"
  rankName: "FAMILY"
  fullName: "Loxocemidae"
,
  id: 784
  taxonomyName: "CITES_EU"
  rankName: "GENUS"
  fullName: "Loxocemus"
,
  id: 7674
  taxonomyName: "CITES_EU"
  rankName: "SPECIES"
  fullName: "Loxocemus bicolor"
,
  id: 1813
  taxonomyName: "CITES_EU"
  rankName: "GENUS"
  fullName: "Loxodonta"
,
  id: 3158
  taxonomyName: "CITES_EU"
  rankName: "SPECIES"
  fullName: "Loxodonta africana"
]