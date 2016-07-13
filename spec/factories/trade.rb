FactoryGirl.define do

  factory :trade_code do
    factory :source, :class => Source do
      sequence(:code) { |n| (97 + n % 26).chr }
      sequence(:name_en) { |n| "Source @{n}" }
    end

    factory :purpose, :class => Purpose do
      sequence(:code) { |n| (97 + n % 26).chr }
      sequence(:name_en) { |n| "Purpose @{n}" }
    end

    factory :term, :class => Term do
      sequence(:code) { |n| [n, n + 1, n + 2].map { |i| (97 + i % 26).chr }.join }
      sequence(:name_en) { |n| "Term @{n}" }
    end

    factory :unit, :class => Unit do
      sequence(:code) { |n| [n, n + 1, n + 2].map { |i| (97 + i % 26).chr }.join }
      sequence(:name_en) { |n| "Unit @{n}" }
    end
  end

  factory :annual_report_upload, :class => Trade::AnnualReportUpload do
    trading_country
    point_of_view 'E'
  end

  factory :validation_rule, :class => Trade::ValidationRule do
    column_names ['taxon_name']
    run_order 1
    factory :presence_validation_rule, :class => Trade::PresenceValidationRule
    factory :numericality_validation_rule, :class => Trade::NumericalityValidationRule
    factory :format_validation_rule, :class => Trade::FormatValidationRule do
      format_re '^\w+$'
    end
    factory :inclusion_validation_rule, :class => Trade::InclusionValidationRule do
      valid_values_view 'valid_taxon_concept_view'
    end
    factory :taxon_concept_appendix_year_validation_rule,
      :class => Trade::TaxonConceptAppendixYearValidationRule do
      column_names ['taxon_concept_id', 'appendix', 'year']
      valid_values_view 'valid_taxon_concept_appendix_year_mview'
    end
    factory :distinct_values_validation_rule,
      :class => Trade::DistinctValuesValidationRule
    factory :taxon_concept_source_validation_rule,
      :class => Trade::TaxonConceptSourceValidationRule
  end

  factory :validation_error, :class => Trade::ValidationError do
    annual_report_upload
    validation_rule
    matching_criteria '{}'
    is_ignored false
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
