FactoryGirl.define do

  factory :annual_report_upload, :class => Trade::AnnualReportUpload do
   csv_source_file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct.csv')) }
  end

  factory :validation_rule, :class => Trade::ValidationRule do
    column_names ['taxon_check']
    factory :presence_validation_rule, :class => Trade::PresenceValidationRule
    factory :numericality_validation_rule, :class => Trade::NumericalityValidationRule
    factory :format_validation_rule, :class => Trade::FormatValidationRule do
      format_re '^\w+$'
    end
  end

end
