require 'spec_helper'

describe Trade::ExportsController do
  describe "GET download" do
    context "raw format" do
      it "returns count of shipments" do
        create(:shipment)
        get :download, :filters => {:report_type => 'raw'}, :format => :json
        parse_json(response.body)['total'].should == 1
      end
      it "returns raw shipments file" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        get :download, :filters => {:report_type => :raw}
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"shipments.csv\"")
      end
      # it "when no results" do
      #   get :download, :filters => {:report_type => :raw}
      #   puts response.body.inspect
      #   response.code.should eql(204)
      # end
      it "logs download information from public interface to the TradeDataDownload model" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        get :download, :filters => {
            :report_type => :raw,
            :exporters_ids => ['40'],
            :time_range_start => '1975',
            :time_range_end => '2000'
          }
        last_download = Trade::TradeDataDownload.last
        last_download.report_type.should eq('raw')
        last_download.year_from.should eq(1975)
      end
      it "does not log download information from the admin interface" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        get :download, :filters => {
            :report_type => :raw, 
            :exporters_ids => ['40'],
            :time_range_start => '1975',
            :time_range_end => '2000'
          }, :internal => true
        last_download = Trade::TradeDataDownload.last
        last_download.should eq(nil)
      end
    end



  end
end
