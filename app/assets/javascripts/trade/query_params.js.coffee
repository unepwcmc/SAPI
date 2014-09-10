Trade.QueryParams = Ember.Mixin.create({

  propertyMapping: [
    {
      name: "selectedTaxonConcepts"
      param: 'selectedTaxonConceptsQP'
      urlParam: 'taxon_concepts_ids'
      type: 'array'
      displayTitle: 'taxa'
      displayProperty: 'fullName'
      collectionPath: null
    },
    {
      name: "selectedReportedTaxonConcepts"
      param: 'selectedReportedTaxonConceptsQP'
      urlParam: 'reported_taxon_concepts_ids'
      type: 'array'
      displayTitle: 'rep. taxa'
      displayProperty: 'fullName'
      collectionPath: null
    },
    {
      name: "selectedAppendices"
      param: 'selectedAppendicesQP'
      urlParam: 'appendices'
      type: 'array'
      displayTitle: 'appdx.'
      displayProperty: 'name'
      collectionPath: 'allAppendices'
    },
    {
      name: "selectedTimeStart"
      param: 'selectedTimeStartQP'
      urlParam: 'time_range_start'
      displayTitle: 'from'
    },
    {
      name: "selectedTimeEnd"
      param: 'selectedTimeEndQP'
      urlParam: 'time_range_end'
      displayTitle: 'to'
    },
    {
      name: "selectedTerms"
      param: 'selectedTermsQP'
      urlParam: 'terms_ids'
      type: 'array'
      displayTitle: 'terms'
      displayProperty: 'name'
      collectionPath: 'controllers.terms'
    },
    {
      name: "selectedUnits"
      param: 'selectedUnitsQP'
      urlParam: 'units_ids'
      type: 'array'
      displayTitle: 'units'
      displayProperty: 'name'
      collectionPath: 'controllers.units'
    },
    {
      name: "selectedPurposes"
      param: 'selectedPurposesQP'
      urlParam: 'purposes_ids'
      type: 'array'
      displayTitle: 'purposes'
      displayProperty: 'name'
      collectionPath: 'controllers.purposes'
    },
    {
      name: "selectedSources"
      param: 'selectedSourcesQP'
      urlParam: 'sources_ids'
      type: 'array'
      displayTitle: 'sources'
      displayProperty: 'name'
      collectionPath: 'controllers.sources'
    },
    {
      name: "selectedImporters"
      param: 'selectedImportersQP'
      urlParam: 'importers_ids'
      type: 'array'
      displayTitle: 'importers'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedExporters"
      param: 'selectedExportersQP'
      urlParam: 'exporters_ids'
      type: 'array'
      displayTitle: 'exporters'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedCountriesOfOrigin"
      param: 'selectedCountriesOfOriginQP'
      urlParam: 'countries_of_origin_ids'
      type: 'array'
      displayTitle: 'origins'
      displayProperty: 'name'
      collectionPath: 'controllers.geoEntities'
    },
    {
      name: "selectedReporterType"
      param: 'selectedReporterTypeQP'
      urlParam: 'reporter_type'
      displayTitle: 'reporter type'
    },
    {
      name: "selectedPermits"
      param: 'selectedPermitsQP'
      urlParam: 'permits_ids'
      type: 'array'
      displayTitle: 'permits'
      displayProperty: 'number'
    },
    {
      name: "selectedQuantity"
      param: 'selectedQuantityQP'
      urlParam: 'quantity'
      displayName: 'quantity'
    },
    {
      name: "unitBlank"
      param: 'unitBlankQP'
      urlParam: 'unit_blank'
      type: 'boolean'
      displayTitle: 'blank unit'
    },
    {
      name: "sourceBlank"
      param: 'sourceBlankQP'
      urlParam: 'source_blank'
      type: 'boolean'
      displayTitle: 'blank source'
    },
    {
      name: "purposeBlank"
      param: 'purposeBlankQP'
      urlParam: 'purpose_blank'
      type: 'boolean'
      displayTitle: 'blank purpose'
    },
    {
      name: "countryOfOriginBlank"
      param: 'countryOfOriginBlankQP'
      urlParam: 'country_of_origin_blank'
      type: 'boolean'
      displayTitle: 'blank origin'
    },
    {
      name: "permitBlank"
      param: 'permitBlankQP'
      urlParam: 'permit_blank'
      type: 'boolean'
      displayTitle: 'blank permit'
    }
  ]
});
