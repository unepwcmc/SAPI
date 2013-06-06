Species.CommonNameRoute = Ember.Route.extend
  model: (params) ->
    Species.CommonName.find(params.common_name_id)
