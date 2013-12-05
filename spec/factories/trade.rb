FactoryGirl.define do

  factory :annual_report_upload, :class => Trade::AnnualReportUpload do
    trading_country
    point_of_view 'E'
  end

  factory :validation_rule, :class => Trade::ValidationRule do
    column_names ['species_name']
    run_order 1
    factory :presence_validation_rule, :class => Trade::PresenceValidationRule
    factory :numericality_validation_rule, :class => Trade::NumericalityValidationRule
    factory :format_validation_rule, :class => Trade::FormatValidationRule do
      format_re '^\w+$'
    end
    factory :inclusion_validation_rule, :class => Trade::InclusionValidationRule do
      valid_values_view 'valid_species_name_view'
    end
    factory :pov_inclusion_validation_rule,
      :class => Trade::PovInclusionValidationRule do
      valid_values_view 'valid_species_name_country_of_origin_view'
    end
    factory :species_name_appendix_year_validation_rule,
      :class => Trade::SpeciesNameAppendixYearValidationRule do
      column_names ['species_name', 'appendix', 'year']
      valid_values_view 'valid_species_name_appendix_year_mview'
    end
    factory :pov_distinct_values_validation_rule,
      :class => Trade::PovDistinctValuesValidationRule
    factory :taxon_concept_source_validation_rule,
      :class => Trade::TaxonConceptSourceValidationRule

  end

  factory :trade_taxon_concept_term_pair, :class => Trade::TaxonConceptTermPair do
    taxon_concept
    term
  end

  factory :shipment, :class => Trade::Shipment do
    taxon_concept
    term
    unit
    purpose
    source
    importer
    exporter
    quantity 1
    year 2013
    appendix 'II'
  end

  factory :permit, :class => Trade::Permit do
    geo_entity
    number 'XXX'
  end
end
