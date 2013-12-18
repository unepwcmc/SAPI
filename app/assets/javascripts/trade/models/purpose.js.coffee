Trade.Purpose = DS.Model.extend
  code: DS.attr('string')
  name: DS.attr('string')
  shipments: DS.hasMany('Trade.Shipment')
  fullName: ( ->
    @get('code') + ' - ' + @get('name')
  ).property('code', 'name')