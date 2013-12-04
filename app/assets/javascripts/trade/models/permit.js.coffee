Trade.Permit = DS.Model.extend
  number: DS.attr("string")
  geoEntity: DS.belongsTo('Trade.GeoEntity')

  displayNumber: (->
    @get('number') + ' (' + @get('geoEntity.isoCode2') + ')'
  ).property('number', 'geoEntity.isoCode2')