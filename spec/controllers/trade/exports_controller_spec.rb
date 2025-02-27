require 'spec_helper'

describe Trade::ExportsController do
  login_admin

  describe 'GET download' do
    context 'raw format' do
      it 'returns count of shipments' do
        create(:shipment)
        get :download, params: { filters: { report_type: 'raw' }, format: :json }
        expect(parse_json(response.body)['total']).to eq(1)
      end
      it 'does not log download information from the admin interface' do
        create(:shipment)
        allow_any_instance_of(Trade::ShipmentsExport).to receive(:public_file_name).and_return('shipments.csv')
        expect do
          get :download, params: {
            filters: {
              report_type: :raw,
              exporters_ids: [ '40' ],
              time_range_start: '1975',
              time_range_end: '2000'
            }
          }
        end.not_to change(Trade::TradeDataDownload, :count)
      end
    end
    context 'when shipments cannot be retrieved' do
      before(:each) do
        allow_any_instance_of(Trade::ShipmentsExport).to receive(:export).and_return(false)
      end
      it 'redirects to home page' do
        get :download, params: { filters: { report_type: :comptab } }
        expect(response).to redirect_to(trade_root_url)
      end
    end
  end
end
