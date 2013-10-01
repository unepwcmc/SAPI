require 'spec_helper'

describe Trade::AnnualReportUploadsController do
  let(:annual_report_upload){ create(:annual_report_upload) }
  describe "GET index" do
    it "should return success" do
      get :index, format: :json
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return success" do
      get :show, id: annual_report_upload.id, format: :json
      response.should be_success
    end
  end

  describe "POST create" do
    def exporter_csv
      test_document = File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')
      Rack::Test::UploadedFile.new(test_document, "text/csv")
    end
    let(:france){
      create(
        :geo_entity,
        :geo_entity_type => create(
          :geo_entity_type, :name => GeoEntityType::COUNTRY
          ),
        :name => 'France',
        :iso_code2 => 'FR'
      )
    }
    it "should return success in jQuery File Upload way" do
      xhr :post, :create,
        :annual_report_upload => {
          :point_of_view => 'E', :trading_country_id => france.id, 
          :csv_source_file => exporter_csv
        }, :format => 'json'
      parse_json(response.body, "files/0")['id'].should_not be_blank
    end
    it "should return error in jQuery File Upload way" do
      xhr :post, :create,
        :annual_report_upload => {
          :point_of_view => 'I', :trading_country_id => france.id,
          :csv_source_file => exporter_csv
        }, :format => 'json'
      parse_json(response.body, "files/0")['id'].should be_blank
    end
  end
end
