FactoryGirl.define do

  factory :trade_code do
    factory :source, :class => Source do
      sequence(:code) { |n| (97 + n%26).chr }
      sequence(:name) { |n| "Source #{n}" }
    end

    factory :purpose, :class => Purpose do
      sequence(:code) { |n| (97 + n%26).chr }
      sequence(:name) { |n| "Purpose #{n}" }
    end

    factory :term, :class => Term do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (97 + i%26).chr }.join }
      sequence(:name) { |n| "Term #{n}" }
    end

    factory :unit, :class => Unit do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (97 + i%26).chr }.join }
      sequence(:name) { |n| "Unit #{n}" }
    end
  end

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
    factory :taxon_concept_appendix_year_validation_rule,
      :class => Trade::TaxonConceptAppendixYearValidationRule do
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

  factory :term_trade_codes_pair do
    term
    trade_code
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
    appendix 'I'
    year 2013
    ignore_warnings true
  end

  factory :permit, :class => Trade::Permit do
    sequence(:number) { |n| "Permit #{n}" }
  end
end
