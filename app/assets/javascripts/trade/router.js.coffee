Trade.Router.map (match)->
  @resource 'annual_report_uploads'

  @resource 'annual_report_upload', { path: 'annual_report_uploads/:annual_report_upload_id' }, ->

    @resource 'sandbox_shipments', { 
      path: 'sandbox_shipments', 
      queryParams: ['page']
    }

  @resource 'validation_rules'
  @resource 'shipments', { 
    queryParams: [
      'page', 'taxon_concepts_ids[]', 'appendices[]', 'time_range_start',
      'time_range_end', 'terms_ids[]', 'units_ids[]', 'purposes_ids[]', 
      'sources_ids[]', 'importers_ids[]', 'exporters_ids[]', 
      'countries_of_origin_ids[]', 'reporter_type', 'permits_ids[]', 'quantity', 
      'unit_blank', 'purpose_blank', 'source_blank', 'country_of_origin_blank']
  }
