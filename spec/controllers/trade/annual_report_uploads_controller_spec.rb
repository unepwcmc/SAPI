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
    before(:each) do
      cites_eu
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @completed_aru = build(:annual_report_upload)
      @completed_aru.save(:validate => false)
      @completed_aru.submit
    end
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
    it "should return nothing" do
      sandbox_shipment = annual_report_upload.sandbox_shipments.first
      filters = {:appendix => sandbox_shipment.appendix}
      updates = {:appendix => "N", :taxon_name => "Canis lupus signatus"}
      xhr :put, :update, :id => annual_report_upload.id,
        :filters => filters, :updates => updates
      response.should be_success
    end
  end
end
