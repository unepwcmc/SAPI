require 'spec_helper'

describe Trade::ExportsController do
  login_admin

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
    context 'when shipments cannot be retrieved' do
      before(:each) do
        Trade::ShipmentsExport.any_instance.stub(:export).and_return(false)
      end
      it "redirects to home page" do
        get :download, :filters => {:report_type => :comptab}
        expect(response).to redirect_to(trade_root_url)
      end
    end

    context 'with ip address to csv separator conversion' do
      it 'sets separator to comma with local ip address' do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("127.0.0.1")
        get :download
        expect(response.cookies['speciesplus.csv_separator']).to_not be_nil
        expect(response.cookies['speciesplus.csv_separator']).to eq(',')
        # Assert it gets passed in params?
      end

      it 'sets separator to comma with UK ip address' do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("194.59.188.126")
        get :download
        expect(response.cookies['speciesplus.csv_separator']).to_not be_nil
        expect(response.cookies['speciesplus.csv_separator']).to eq(',')
        # Assert it gets passed in params?
      end

      it 'sets separator to semicolon with AF ip address' do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("175.106.59.78")
        get :download
        expect(response.cookies['speciesplus.csv_separator']).to_not be_nil
        expect(response.cookies['speciesplus.csv_separator']).to eq(';')
        # Assert it gets passed in params?
      end

      it 'sets separator back to comma when a user overrides the encoded default' do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("175.106.59.78")
        get :download, :filters => {
          :csv_separator => ','
        }
        expect(response.cookies['speciesplus.csv_separator']).to_not be_nil
        expect(response.cookies['speciesplus.csv_separator']).to eq(',')
        # Assert it gets passed in params?
      end
    end
  end
end
