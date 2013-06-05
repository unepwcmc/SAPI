Species.Adapter = DS.RESTAdapter.reopen
  namespace: 'api/v1'
  ajax: (url, type, hash) ->
    hash.success = (json, e, xhr) ->
      @pagination = xhr.getResponseHeader('X-Pagination')
      console.log(xhr.getResponseHeader('X-Pagination'))
    return this._super(url, type, hash)


Species.Store = DS.Store.extend
  revision: 12
  adapter: 'DS.RESTAdapter'
