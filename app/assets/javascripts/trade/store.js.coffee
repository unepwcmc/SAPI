Trade.Store = DS.Store.extend({
  revision: 12
})

DS.RESTAdapter.registerTransform('array',
  serialize: (value) ->
    if (Em.typeOf(value) == 'array')
      return value
    else
      return []
  deserialize: (value) ->
    return value
)

Trade.Store.registerAdapter('Trade.GeoEntity', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))

DS.RESTAdapter.configure("plurals", { geo_entity: "geo_entities" })

Trade.Adapter = DS.RESTAdapter.reopen({
  namespace: 'trade'
})
