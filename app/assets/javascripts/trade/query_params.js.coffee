Trade.QueryParams = Ember.Mixin.create({

  queryParamsProperties: (->
    result = {}
    @get('selectedQueryParamNames').forEach (property) =>
      result[property.name] = {
        param: property.param
        urlParam: property.urlParam
      }
    result
  ).property('selectedQueryParamNames')

  selectedQueryParamNames: [
    {
      name: "selectedTaxonConcepts"
      param: 'taxon_concepts_ids[]'
      urlParam: 'taxon_concepts_ids'
    },
    {
      name: "selectedAppendices"
      param: 'appendices[]'
      urlParam: 'appendices'
    },
    {
      name: "selectedTimeStart"
      param: 'time_range_start'
      urlParam: 'time_range_start'
    },
    {
      name: "selectedTimeEnd"
      param: 'time_range_end'
      urlParam: 'time_range_end'
    },
    {
      name: "selectedTerms"
      param: 'terms_ids[]'
      urlParam: 'terms_ids'
    },
    {
      name: "selectedUnits"
      param: 'units_ids[]'
      urlParam: 'units_ids'
    },
    {
      name: "selectedPurposes"
      param: 'purposes_ids[]'
      urlParam: 'purposes_ids'
    },
    {
      name: "selectedSources"
      param: 'sources_ids[]'
      urlParam: 'sources_ids'
    },
    {
      name: "selectedImporters"
      param: 'importers_ids[]'
      urlParam: 'importers_ids'
    },
    {
      name: "selectedExporters"
      param: 'exporters_ids[]'
      urlParam: 'exporters_ids'
    },
    {
      name: "selectedCountriesOfOrigin"
      param: 'countries_of_origin_ids[]'
      urlParam: 'countries_of_origin_ids'
    },
    {
      name: "selectedReporterTypeValues"
      param: 'reporter_type'
      urlParam: 'reporter_type'
    },
    {
      name: "selectedPermits"
      param: 'permits_ids[]'
      urlParam: 'permits_ids'
    },
    {
      name: "selectedQuantity"
      param: 'quantity'
      urlParam: 'quantity'
    },
    {
      name: "unitBlank"
      param: 'unit_blank'
      urlParam: 'unit_blank'
    },
    {
      name: "sourceBlank"
      param: 'source_blank'
      urlParam: 'source_blank'
    },
    {
      name: "purposeBlank"
      param: 'purpose_blank'
      urlParam: 'purpose_blank'
    },
    {
      name: "countryOfOriginBlank"
      param: 'country_of_origin_blank'
      urlParam: 'country_of_origin_blank'
    }
  ]
});