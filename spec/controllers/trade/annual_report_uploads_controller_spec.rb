require 'spec_helper'

describe Trade::AnnualReportUploadsController do
  let(:trade_annual_report_upload){ create(:trade_annual_report_upload) }
  describe "GET index" do
    it "should return success" do
      get :index, format: :json
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return success" do
      get :show, id: trade_annual_report_upload.id, format: :json
      response.should be_success
    end
  end

  describe "POST create" do
    def correct_csv
      test_document = File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct.csv')
      Rack::Test::UploadedFile.new(test_document, "text/csv")
    end
    it "should return success in jQuery File Upload way" do
      xhr :post, :create, :csv_source_file => correct_csv, :format => 'json'
      parse_json(response.body, "files/0")['id'].should_not be_blank
    end
    def incorrect_csv
      test_document = File.join(Rails.root, 'spec', 'support', 'annual_report_upload_incorrect.csv')
      Rack::Test::UploadedFile.new(test_document, "text/csv")
    end
    it "should return error in jQuery File Upload way" do
      xhr :post, :create, :csv_source_file => incorrect_csv, :format => 'json'
      parse_json(response.body, "files/0")['id'].should be_blank
    end
  end
end
