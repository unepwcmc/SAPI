Trade.QueryParams = Ember.Mixin.create({

  # note: this maps a property on the controller to a query param
  # changing a property will change the url
  queryParams: [
    'page',
    'selectedTaxonConceptsQP:taxon_concepts_ids',
    'selectedReportedTaxonConceptsQP:reported_taxon_concepts_ids',
    'selectedAppendicesQP:appendices',
    'selectedTimeStartQP:time_range_start',
    'selectedTimeEndQP:time_range_end',
    'selectedTermsQP:terms_ids',
    'selectedUnitsQP:units_ids',
    'selectedPurposesQP:purposes_ids',
    'selectedSourcesQP:sources_ids',
    'selectedReporterTypeQP:reporter_type',
    'selectedImportersQP:importers_ids',
    'selectedExportersQP:exporters_ids',
    'selectedCountriesOfOriginQP:countries_of_origin_ids',
    'selectedPermitsQP:permits_ids',
    'selectedQuantityQP:quantity',
    'unitBlankQP:unit_blank',
    'purposeBlankQP:purpose_blank',
    'sourceBlankQP:source_blank',
    'countryOfOriginBlankQP:country_of_origin_blank',
    'permitBlankQP:permit_blank'
  ]

  # need to initialize those array query params
  # otherwise they're not passed as arrays
  selectedTaxonConceptsQP: []
  selectedReportedTaxonConceptsQP: []
  selectedAppendicesQP: []
  selectedTermsQP: []
  selectedUnitsQP: []
  selectedPurposesQP: []
  selectedSourcesQP: []
  selectedImportersQP: []
  selectedExportersQP: []
  selectedCountriesOfOriginQP: []
  selectedPermitsQP: []

  propertyMapping: [
    {
      name: "selectedTaxonConcepts"
      param: 'selectedTaxonConceptsQP'
      urlParam: 'taxon_concepts_ids'
      type: 'array'
    },
    {
      name: "selectedReportedTaxonConcepts"
      param: 'selectedReportedTaxonConceptsQP'
      urlParam: 'reported_taxon_concepts_ids'
      type: 'array'
    },
    {
      name: "selectedAppendices"
      param: 'selectedAppendicesQP'
      urlParam: 'appendices'
      type: 'array'
    },
    {
      name: "selectedTimeStart"
      param: 'selectedTimeStartQP'
      urlParam: 'time_range_start'
    },
    {
      name: "selectedTimeEnd"
      param: 'selectedTimeEndQP'
      urlParam: 'time_range_end'
    },
    {
      name: "selectedTerms"
      param: 'selectedTermsQP'
      urlParam: 'terms_ids'
      type: 'array'
    },
    {
      name: "selectedUnits"
      param: 'selectedUnitsQP'
      urlParam: 'units_ids'
      type: 'array'
    },
    {
      name: "selectedPurposes"
      param: 'selectedPurposesQP'
      urlParam: 'purposes_ids'
      type: 'array'
    },
    {
      name: "selectedSources"
      param: 'selectedSourcesQP'
      urlParam: 'sources_ids'
      type: 'array'
    },
    {
      name: "selectedImporters"
      param: 'selectedImportersQP'
      urlParam: 'importers_ids'
      type: 'array'
    },
    {
      name: "selectedExporters"
      param: 'selectedExportersQP'
      urlParam: 'exporters_ids'
      type: 'array'
    },
    {
      name: "selectedCountriesOfOrigin"
      param: 'selectedCountriesOfOriginQP'
      urlParam: 'countries_of_origin_ids'
      type: 'array'
    },
    {
      name: "selectedReporterType"
      param: 'selectedReporterTypeQP'
      urlParam: 'reporter_type'
    },
    {
      name: "selectedPermits"
      param: 'selectedPermitsQP'
      urlParam: 'permits_ids'
      type: 'array'
    },
    {
      name: "selectedQuantity"
      param: 'selectedQuantityQP'
      urlParam: 'quantity'
    },
    {
      name: "unitBlank"
      param: 'unitBlankQP'
      urlParam: 'unit_blank'
      type: 'boolean'
    },
    {
      name: "sourceBlank"
      param: 'sourceBlankQP'
      urlParam: 'source_blank'
      type: 'boolean'
    },
    {
      name: "purposeBlank"
      param: 'purposeBlankQP'
      urlParam: 'purpose_blank'
      type: 'boolean'
    },
    {
      name: "countryOfOriginBlank"
      param: 'countryOfOriginBlankQP'
      urlParam: 'country_of_origin_blank'
      type: 'boolean'
    },
    {
      name: "permitBlank"
      param: 'permitBlankQP'
      urlParam: 'permit_blank'
      type: 'boolean'
    }
  ]
});
