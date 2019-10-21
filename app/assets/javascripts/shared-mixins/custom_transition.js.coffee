# This mixin is used to replicate the functionality of using Embers transitions, but still retain the query params in the url. Query params are supported by Ember, but only in later versions.
# The helpers below simply take the query parameters that are passed to the customTransition function and form a query string that matches the Ember generated one.
# customTransitionToRoute has the same method signature as transitionToRoute, so should be easy to switch back to Ember's built in functionality in the future.

# @refresh has been used in queryParamsDidChange in ..._route.js files to make sure that the new model is loaded when the parameters change. This might be able to be removed when updating Ember.

ROUTES = {
  'documents': 'documents',
  'taxonConcept': 'taxon_concepts',
  'taxonConcepts': 'taxon_concepts',
  'legal': 'legal'
}

getQueryString = (queryParams) -> 
  queryString = '?'

  queryString += Object.keys(queryParams).map((key) =>
    getQueryStringItem(key, queryParams[key])
  ).filter(isNotUndefinedOrNull).join('&')

getQueryStringItem = (key, param) ->    
  if Array.isArray(param)
    getArrayQueryStringItem(key, param)
  else if isNotUndefinedOrNull(param)
    key + '=' + param

getArrayQueryStringItem = (queryKey, queryArray) ->
  queryKey + '=' + queryArray.map((param) => 
    param
  ).join('%2C')

isNotUndefinedOrNull = (x) ->
  x != undefined && x != null

@CustomTransition = Ember.Mixin.create
  customTransitionToRoute: (emberRoute, arg2, arg3) ->
    @assignArguments(arguments)
    path = @getPath()

    base_url = window.location.origin + '/#/' + path
    queryString = if @queryParams then getQueryString(@queryParams) else ''

    window.location.href = base_url + queryString

  assignArguments: (args) ->
    emberRoute = args[0]
    @pathArray = emberRoute.split('.').map((path) => ROUTES[path])

    if args.length <= 2
      params = args[1]
      @queryParams = if params then params.queryParams else null
    else
      params = args[2]
      @queryParams = if params then params.queryParams else null
      @model = args[1]

  getPath: () ->
    if @model == undefined
      @pathArray[0]
    else 
      @pathArray[0] + '/' + @model.get('id') + '/' + @pathArray[1]
