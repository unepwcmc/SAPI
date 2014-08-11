FactoryGirl.define do

  factory :document do
    date { Date.today }
    filename { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')) }
    event
    type 'Document'
  end

end
