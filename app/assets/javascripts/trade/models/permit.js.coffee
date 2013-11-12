Trade.Permit = DS.Model.extend
  code: DS.attr('string')
  geoEntity: DS.belongsTo('Trade.GeoEntity', {
    inverse: 'permits'
  })