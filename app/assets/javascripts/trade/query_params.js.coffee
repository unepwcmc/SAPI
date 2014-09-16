Trade.QueryParams = Ember.Mixin.create({

  propertyMapping: [
    {
      name: "selectedTaxonConcepts"
      urlParam: 'taxon_concepts_ids'
      type: 'array'
      displayTitle: 'taxa'
      displayProperty: 'fullName'
      collectionPath: null
    },
    {
      name: "selectedReportedTaxonConcepts"
      urlParam: 'reported_taxon_concepts_ids'
      type: 'array'
      displayTitle: 'rep. taxa'
      displayProperty: 'fullName'
      collectionPath: null
    },
    {
      name: "selectedAppendices"
      urlParam: 'appendices'
      type: 'array'
      displayTitle: 'appdx.'
      displayProperty: 'name'
      collectionPath: 'allAppendices'
    },
    {
      name: "selectedTimeStart"
      urlParam: 'time_range_start'
      displayTitle: 'from'
    },
    {
      name: "selectedTimeEnd"
      urlParam: 'time_range_end'
      displayTitle: 'to'
    },
    {
      name: "selectedTerms"
      urlParam: 'terms_ids'
      type: 'array'
      displayTitle: 'terms'
      displayProperty: 'name'
      collectionPath: 'controllers.terms'
    },
    {
      name: "selectedUnits"
      urlParam: 'units_ids'
      type: 'array'
      displayTitle: 'units'
      displayProperty: 'name'
      collectionPath: 'controllers.units'
    },
    {
      name: "selectedPurposes"
      urlParam: 'purposes_ids'
      type: 'array'
      displayTitle: 'purposes'
      displayProperty: 'name'
      collectionPath: 'controllers.purposes'
    },
    {
      name: "selectedSources"
      urlParam: 'sources_ids'
      type: 'array'
      displayTitle: 'sources'
      displayProperty: 'name'
      collectionPath: 'controllers.sources'
    },
    {
      name: "selectedImporters"
      urlParam: 'importers_ids'
      type: 'array'
      displayTitle: 'importers'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedExporters"
      urlParam: 'exporters_ids'
      type: 'array'
      displayTitle: 'exporters'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedCountriesOfOrigin"
      urlParam: 'countries_of_origin_ids'
      type: 'array'
      displayTitle: 'origins'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedReporterType"
      urlParam: 'reporter_type'
      displayTitle: 'reporter type'
    },
    {
      name: "selectedPermits"
      urlParam: 'permits_ids'
      type: 'array'
      displayTitle: 'permits'
      displayProperty: 'number'
    },
    {
      name: "selectedQuantity"
      urlParam: 'quantity'
      displayName: 'quantity'
    },
    {
      name: "unitBlank"
      urlParam: 'unit_blank'
      type: 'boolean'
      displayTitle: 'blank unit'
    },
    {
      name: "sourceBlank"
      urlParam: 'source_blank'
      type: 'boolean'
      displayTitle: 'blank source'
    },
    {
      name: "purposeBlank"
      urlParam: 'purpose_blank'
      type: 'boolean'
      displayTitle: 'blank purpose'
    },
    {
      name: "countryOfOriginBlank"
      urlParam: 'country_of_origin_blank'
      type: 'boolean'
      displayTitle: 'blank origin'
    },
    {
      name: "permitBlank"
      urlParam: 'permit_blank'
      type: 'boolean'
      displayTitle: 'blank permit'
    }
  ]
});
