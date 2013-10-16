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
    factory :species_name_appendix_year_validation_rule,
      :class => Trade::SpeciesNameAppendixYearValidationRule do
      valid_values_view 'valid_species_name_appendix_year_mview'
    end
  end

end
