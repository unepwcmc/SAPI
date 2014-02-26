require 'spec_helper'

describe Trade::ExportsController do
  describe "GET download" do
    context "raw format" do
      it "returns count of shipments" do
        create(:shipment)
        get :download, :filters => {:report_type => 'raw'}, :format => :json
        parse_json(response.body)['total'].should == 1
      end
      it "does not log download information from the admin interface" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        lambda do
          get :download, :filters => {
              :report_type => :raw,
              :exporters_ids => ['40'],
              :time_range_start => '1975',
              :time_range_end => '2000'
            }
        end.should_not change(Trade::TradeDataDownload, :count).by(1)
      end
    end



  end
end
