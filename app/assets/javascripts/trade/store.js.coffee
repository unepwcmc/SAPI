DS.RESTAdapter.registerTransform('array',
  serialize: (value) ->
    if (Em.typeOf(value) == 'array')
      return value
    else
      return []
  deserialize: (value) ->
    return value
)

DS.RESTAdapter.configure("plurals", { geo_entity: "geo_entities" });

Trade.Adapter = DS.RESTAdapter.reopen({
  namespace: 'trade'
})

Trade.Store = DS.Store.extend({
  revision: 12
})
