Trade.Unit = DS.Model.extend
  code: DS.attr('string')
  nameEn: DS.attr('string')
  shipments: DS.hasMany('Trade.Shipment')
  fullName: ( ->
    @get('code') + ' - ' + @get('nameEn')
  ).property('code', 'nameEn')
