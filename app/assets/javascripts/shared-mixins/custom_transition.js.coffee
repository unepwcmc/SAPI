# This mixin is used to replicate the functionality of using Embers transitions, but still retain the query params in the url. Query params are supported by Ember, but only in later versions.
# The helpers below simply take the query parameters that are passed to the customTransition function and form a query string that matches the Ember generated one.
# customTransitionToRoute has the same method signature as transitionToRoute, so should be easy to switch back to Ember's built in functionality in the future.

# @refresh has been used in queryParamsDidChange in ..._route.js files to make sure that the new model is loaded when the parameters change. This might be able to be removed when updating Ember.

# Note the trade and species apps both pass array parameters differently.

ROUTES = {
  species: {
    'taxonConcept': {
      urlPath: 'taxon_concepts',
      followedById: true
    },
    'taxonConcepts': {
      urlPath: 'taxon_concepts',
    }
  },
  trade : {
    'annual_report_upload': {
      urlPath: 'annual_report_uploads',
      followedById: true
    }
  }
}

isNotUndefinedOrNull = (x) ->
  x != undefined && x != null

@CustomTransitionMixinCreate = (App, appName) -> 
  App.CustomTransition = Ember.Mixin.create
    customTransitionToRoute: (emberRoute, arg2, arg3) ->
      @routes = ROUTES[appName]
      @appName = appName
      @paramsMapping = @get('propertyMapping')

      @assignArguments(arguments)
      path = @getPath()
      base_url = window.location.origin + '/' + @appName + '#/' + path
      queryString = if @queryParams then @getQueryString(@queryParams) else ''
      
      window.location.href = base_url + queryString

    assignArguments: (args) ->
      emberRoute = args[0]
      @pathArray = @getPathArray(emberRoute)

      if args.length <= 2
        params = args[1]
        @queryParams = if params then params.queryParams else null
      else
        params = args[2]
        @queryParams = if params then params.queryParams else null
        @model = args[1]
    
    getPathArray: (emberRoute) ->
      pathArray = []

      emberRoute.split('.').forEach (pathElement) => 
        pathArray.push(@getUrlPathItem(pathElement))
        if @routes[pathElement] && @routes[pathElement].followedById
          pathArray.push('_ID_')
      
      return pathArray

    getUrlPathItem: (name) ->
      urlPath = if @routes[name] then @routes[name].urlPath else name

    getPath: () ->
      @pathArray.map(@replaceWithModelId).join('/')

    replaceWithModelId: (el) ->
      if el == '_ID_' then @model.get('id') else el

    getQueryString: (queryParams) -> 
      queryString = '?'

      if @appName == 'trade'
        queryString += $.param(queryParams)
      else
        queryString += Object.keys(queryParams).map((key) =>
          @getQueryStringItem(key, queryParams[key])
        ).filter(isNotUndefinedOrNull).join('&')

    getQueryStringItem: (key, param) ->    
      if Array.isArray(param)
        @getArrayQueryStringItem(key, param)
      else if isNotUndefinedOrNull(param)
        @getUrlParam(key) + '=' + param

    getArrayQueryStringItem: (queryKey, queryArray) ->
      @getUrlParam(queryKey) + '=' + queryArray.join('%2C')

    getUrlParam: (paramName) ->
      urlParam = paramName

      if @paramsMapping
        @paramsMapping.forEach (paramConfig) ->
          if paramConfig.name == paramName
            urlParam = paramConfig.urlParam
      
      return urlParam