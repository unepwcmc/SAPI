# encoding: utf-8
require 'spec_helper'

describe CitesTrade::ExportsController do
  describe "GET download" do
    context "raw format" do
      it "returns count of shipments" do
        create(:shipment)
        get :download, :filters => {:report_type => 'raw'}, :format => :json
        parse_json(response.body)['total'].should == 1
      end
      it "returns comptab shipments file" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        Trade::TradeDataDownloadLogger.stub(:city_country_from).and_return(["Cambridge", "United Kingdom"])
        Trade::TradeDataDownloadLogger.stub(:organization_from).and_return("UNEP-WCMC")
        get :download, :filters => {:report_type => :comptab}
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
      it "converts LATIN1 geo data to UTF8 before saving" do
        create(:shipment)
        latin1_city = "Bogotá".encode('ISO-8859-1', 'UTF-8')
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        Trade::TradeDataDownloadLogger.stub(:city_country_from).and_return([latin1_city, "Colombia"])
        Trade::TradeDataDownloadLogger.stub(:organization_from).and_return("Telecomunicaciones S.A. Esp")

        get :download, :filters => {
            :report_type => 'comptab',
            :exporters_ids => ['40'],
            :time_range_start => '1975',
            :time_range_end => '2000'
          }

        download = Trade::TradeDataDownload.last
        download.city.should == "Bogotá"
      end
    end



  end
end
