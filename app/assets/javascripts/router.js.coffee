SAPI.Router.map (match)->
  @resource 'annual_reports', ()->
    @resource 'annual_report', { path: ':annual_report_id' }
