require 'spec_helper'

describe Trade::AnnualReportUploadsController do
  login_admin

  let(:france) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'France',
      iso_code2: 'FR'
    )
  end
  let(:annual_report_upload) do
    create(
      :annual_report_upload,
      point_of_view: 'E',
      trading_country_id: france.id,
      csv_source_file: exporter_csv
    )
  end

  def exporter_csv
    test_document = Rails.root.join('spec/support/annual_report_upload_exporter.csv').to_s
    Rack::Test::UploadedFile.new(test_document, 'text/csv')
  end

  describe 'GET index' do
    before do
      cites_eu
      @aru = build(:annual_report_upload)
      @aru.save(validate: false)
      @completed_aru = build(:annual_report_upload)
      @completed_aru.save(validate: false)
      @completed_aru.update(submitted_at: Time.now)
    end

    it 'returns all annual report uploads' do
      get :index, format: :json
      expect(response.body).to have_json_size(2).at_path('annual_report_uploads')
    end

    it 'returns annual report uploads in progress' do
      get :index, params: { is_done: 0, format: :json }
      expect(response.body).to have_json_size(1).at_path('annual_report_uploads')
    end
  end

  describe 'GET show' do
    it 'returns success' do
      get :show, params: { id: annual_report_upload.id, format: :json }
      expect(response.body).to have_json_path('annual_report_upload')
    end
  end

  describe 'POST create' do
    it 'returns success in jQuery File Upload way' do
      post :create, params: {
        annual_report_upload: {
          point_of_view: 'E', trading_country_id: france.id,
          csv_source_file: exporter_csv
        }
      }, xhr: true, format: 'json'
      expect(parse_json(response.body, 'files/0')['id']).not_to be_blank
    end

    it 'returns error in jQuery File Upload way' do
      post :create, params: {
        annual_report_upload: {
          point_of_view: 'I', trading_country_id: france.id,
          csv_source_file: exporter_csv
        }
      }, format: 'json', xhr: true
      expect(parse_json(response.body, 'files/0')['id']).to be_blank
    end
  end
end
