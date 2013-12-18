Trade.TaxonConcept = DS.Model.extend
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  authorYear: DS.attr("string")
  shipments: DS.hasMany('Trade.Shipment')
