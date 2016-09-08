# encoding: utf-8
require 'spec_helper'

describe CitesTrade::ExportsController do
  describe "GET download" do
    context "raw format" do
      it "returns count of shipments" do
        create(:shipment)
        get :download, :filters => { :report_type => 'raw' }, :format => :json
        parse_json(response.body)['total'].should == 1
      end
    end
    context "comptab" do
      it "returns comptab shipments file" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        Trade::TradeDataDownloadLogger.stub(:city_country_from).and_return(["Cambridge", "United Kingdom"])
        Trade::TradeDataDownloadLogger.stub(:organization_from).and_return("UNEP-WCMC")
        get :download, :filters => { :report_type => :comptab }
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"shipments.csv\"")
      end
      it "logs download information from public interface to the TradeDataDownload model" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        Trade::TradeDataDownloadLogger.stub(:city_country_from).and_return(["Cambridge", "United Kingdom"])
        Trade::TradeDataDownloadLogger.stub(:organization_from).and_return("UNEP-WCMC")
        lambda do
          get :download, :filters => {
            :report_type => 'comptab',
            :exporters_ids => ['40'],
            :time_range_start => '1975',
            :time_range_end => '2000'
          }
        end.should change(Trade::TradeDataDownload, :count).by(1)
      end
    end
    context 'when shipments cannot be retrieved' do
      before(:each) do
        Trade::ShipmentsExport.any_instance.stub(:export).and_return(false)
      end
      it "redirects to home page" do
        get :download, :filters => { :report_type => :comptab }
        expect(response).to redirect_to(cites_trade_root_url)
      end
    end
  end
end
