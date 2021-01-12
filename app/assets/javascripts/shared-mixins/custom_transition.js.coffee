# This mixin is used to replicate the functionality of using Embers transitions, but still retain the query params in the url. Query params are supported by Ember, but only in later versions.
# The helpers below simply take the query parameters that are passed to the customTransition function and form a query string that matches the Ember generated one.
# customTransitionToRoute has the same method signature as transitionToRoute, so should be easy to switch back to Ember's built in functionality in the future.

# @refresh has been used in queryParamsDidChange in ..._route.js files to make sure that the new model is loaded when the parameters change. This might be able to be removed when updating Ember.

# Note the trade and species apps both pass array parameters differently.

ROUTES = {
  species: {
    'taxonConcept': {
      urlPath: 'taxon_concepts/_ID_',
    },
    'taxonConcepts': {
      urlPath: 'taxon_concepts',
    }
  },
  trade : {
    'annual_report_upload': {
      urlPath: 'annual_report_uploads/_ID_',
    },
    'sandbox_shipments': {
      urlPath:'annual_report_uploads/_ID_/sandbox_shipments'
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
      @pathWithIDPlaceholder = @getPathWithIDPlaceholder(emberRoute)

      if args.length <= 2
        params = args[1]
        @queryParams = if params then params.queryParams else null
      else
        params = args[2]
        @queryParams = if params then params.queryParams else null
        @model = args[1]
    
    getPathWithIDPlaceholder: (emberRoute) ->
      pathArray = []

      emberRoute.split('.').forEach (pathElement) => 
        pathArray.push(@getUrlPathItem(pathElement))
      
      return pathArray.join('/')

    getUrlPathItem: (name) ->
      urlPath = if @routes[name] then @routes[name].urlPath else name

    getPath: () ->
      if @pathWithIDPlaceholder.match(/_ID_/)
        return @pathWithIDPlaceholder.replace('_ID_', @model.get('id'))

      return @pathWithIDPlaceholder

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

    getParameterByName: (name, url = window.location.href) ->
      name = name.replace(/[\[\]]/g, '\\$&')
      regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)')
      results = regex.exec(url)
      if !results
        return null
      if !results[2]
        return ''
      decodeURIComponent results[2].replace(/\+/g, ' ')

    removeParam: (key, sourceURL) ->
      rtn = sourceURL.split('?')[0]
      param = undefined
      params_arr = []
      queryString = if sourceURL.indexOf('?') != -1 then sourceURL.split('?')[1] else ''
      if queryString != ''
        params_arr = queryString.split('&')
        i = params_arr.length - 1
        while i >= 0
          param = params_arr[i].split('=')[0]
          if param == key
            params_arr.splice i, 1
          i -= 1
        rtn = rtn + '?' + params_arr.join('&')
      rtn