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
    getArrayQueryString(key, param)
  else if isNotUndefinedOrNull(param)
    key + '=' + param

getArrayQueryString = (queryKey, queryArray) ->
  queryKey + '=' + queryArray.map((param) => 
    param
  ).join('%2C')

isNotUndefinedOrNull = (x) ->
  x != undefined && x != null

Species.CustomTransition = Ember.Mixin.create
  customTransitionToRoute: (emberRoute, arg2, arg3) ->
    @assignArguments(arguments)
    path = @getPath()

    base_url = window.location.origin + '/#/' + path
    queryString = if @queryParams then getQueryString(@queryParams) else ''

    window.location.href = base_url + queryString

  assignArguments: (args) ->
    emberRoute = args[0]
    @pathArray = emberRoute.split('.').map((route) => ROUTES[route])

    if arguments.length <= 2
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
      @pathArray[0] + '/' + @model + '/' + @pathArray[1]
