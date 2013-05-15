FactoryGirl.define do

  factory :trade_annual_report_upload, :class => Trade::AnnualReportUpload do
   csv_source_file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct.csv')) }
  end

end
