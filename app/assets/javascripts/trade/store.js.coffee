Trade.Adapter = DS.RESTAdapter.reopen({
  namespace: 'trade'
});

Trade.Store = DS.Store.extend({
  revision: 12
});
