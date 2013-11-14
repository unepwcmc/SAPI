Trade.QueryParams = Ember.Mixin.create({
  selectedQueryParamNames: [
    {
      name: "selectedAppendixValues"
      param: 'appendices[]'
    },
    {
      name: "selectedTimeStart"
      param: 'time_range_start'
    },
    {
      name: "selectedTimeEnd"
      param: 'time_range_end'
    },
    {
      name: "selectedTermCodeValues"
      param: 'terms_ids[]'
    },
    {
      name: "selectedUnitsCodeValues"
      param: 'units_ids[]'
    },
    {
      name: "selectedPurposesCodeValues"
      param: 'purposes_ids[]'
    },
    {
      name: "selectedSourcesCodeValues"
      param: 'sources_ids[]'
    },
    {
      name: "selectedImporterValues"
      param: 'importers_ids[]'
    },
    {
      name: "selectedExporterValues"
      param: 'exporters_ids[]'
    },
    {
      name: "selectedCountryOfOriginValues"
      param: 'countries_of_origin_ids[]'
    },
    {
      name: "selectedReporterTypeValues"
      param: 'reporter_type'
    },
    {
      name: "selectedPermitProperties"
      param: 'permits_ids[]'
    }
  ]
});