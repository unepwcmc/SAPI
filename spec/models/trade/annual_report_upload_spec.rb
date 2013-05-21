require 'spec_helper'

describe Trade::AnnualReportUpload do
  describe :valid? do
    context "when uploaded file has all possible column headers" do
      subject{
        build(
          :annual_report_upload,
          :csv_source_file => Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct.csv'))
        )
      }
      specify {subject.should be_valid}
    end
    context "when uploaded file has only required column headers" do
      subject{
        build(
          :annual_report_upload,
          :csv_source_file => Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct_all_columns.csv'))
        )
      }
      specify {subject.should be_valid}
    end
    context "when uploaded file does not have some of the required column headers" do
      subject{
        build(
          :annual_report_upload,
          :csv_source_file => Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_incorrect.csv'))
        )
      }
      specify {subject.should_not be_valid}
    end
  end
end
