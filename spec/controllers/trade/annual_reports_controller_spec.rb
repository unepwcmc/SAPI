require 'spec_helper'

describe Trade::AnnualReportsController do
  let(:trade_annual_report){ create(:trade_annual_report) }
  describe "GET index" do
    it "should return success" do
      get :index, format: :json
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return success" do
      get :show, id: trade_annual_report.id, format: :json
      response.should be_success
    end
  end
end
