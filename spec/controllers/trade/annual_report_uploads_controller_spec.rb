require 'spec_helper'

describe Trade::AnnualReportUploadsController do
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
  def exporter_csv
    test_document = File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')
    Rack::Test::UploadedFile.new(test_document, "text/csv")
  end
  let(:annual_report_upload){
    create(
      :annual_report_upload,
      :point_of_view => 'E',
      :trading_country_id => france.id, 
      :csv_source_file => exporter_csv
    )
  }
  describe "GET index" do
    let!(:annual_report_upload){ create(:annual_report_upload) }
    let!(:annual_report_upload_completed){
      aru = create(:annual_report_upload)
      aru.submit
      aru
    }
    it "should return all annual report uploads" do
      get :index, format: :json
      response.body.should have_json_size(2).at_path('annual_report_uploads')
    end
    it "should return annual report uploads in progress" do
      get :index, is_done: 0, format: :json
      response.body.should have_json_size(1).at_path('annual_report_uploads')
    end
 end

  describe "GET show" do
    it "should return success" do
      get :show, id: annual_report_upload.id, format: :json
      response.body.should have_json_path('annual_report_upload')
    end
  end

  describe "POST create" do
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

  describe "PUT update" do
    it "should return updated object" do
      xhr :put, :update, :id => annual_report_upload.id,
        :annual_report_upload => annual_report_upload.attributes.
        merge(:sandbox_shipments => annual_report_upload.sandbox_shipments)
      response.body.should have_json_path('annual_report_upload')
    end
  end
end
