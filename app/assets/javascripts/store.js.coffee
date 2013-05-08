DS.RESTAdapter.reopen({
  namespace: 'trade'
});

SAPI.Store = DS.Store.extend({
  revision: 12
});
