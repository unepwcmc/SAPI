FactoryGirl.define do

  factory :trade_annual_report_upload, :class => Trade::AnnualReportUpload do
    original_filename 'data.csv'
  end

end
