#Species.Adapter = DS.RESTAdapter.reopen({
#  namespace: 'api'
#})

Species.Store = DS.Store.extend(
  revision: 12
  adapter: 'DS.FixtureAdapter'
)