Trade.Store = DS.Store.extend({
  revision: 12
  adapter: 'DS.RESTAdapter'
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

DS.RESTAdapter.registerTransform('hash',
  serialize: (value) ->
    if (Em.typeOf(value) == 'hash')
      return value
    else
      return {}
  deserialize: (value) ->
    return value
)

Trade.Store.registerAdapter('Trade.GeoEntity', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.Term', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.Unit', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.Purpose', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.Source', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.TaxonConcept', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))
Trade.Store.registerAdapter('Trade.AutoCompleteTaxonConcept', DS.RESTAdapter.extend({
  namespace: "api/v1"
}))

DS.RESTAdapter.configure("plurals", { geo_entity: "geo_entities" })

Trade.Adapter = DS.RESTAdapter.reopen({
  namespace: 'trade'

  didFindQuery: (store, type, payload, recordArray) ->
    loader = DS.loaderFor(store)

    loader.populateArray = (data) ->
      recordArray.load(data)
      # This adds the meta property returned from the server
      # onto the recordArray sent back
      recordArray.set('meta', payload.meta)

    @get('serializer').extractMany(loader, payload, type)
})
