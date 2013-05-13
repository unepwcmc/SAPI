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
end
