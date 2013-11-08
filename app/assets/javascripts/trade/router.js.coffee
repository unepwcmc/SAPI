Trade.Router.map (match)->
  @resource 'annual_report_uploads'
  @resource 'annual_report_upload', { path: 'annual_report_uploads/:annual_report_upload_id' }
  @resource 'validation_rules'
  @resource 'shipments', { queryParams: ['page'] }
