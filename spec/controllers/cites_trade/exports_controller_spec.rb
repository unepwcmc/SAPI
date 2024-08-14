# encoding: utf-8

require 'spec_helper'

describe CitesTrade::ExportsController do
  describe 'GET download' do
    context 'raw format' do
      it 'returns count of shipments' do
        create(:shipment)
        get :download, params: { filters: { report_type: 'raw' }, format: :json }
        expect(parse_json(response.body)['total']).to eq(1)
      end
    end
    context 'comptab' do
      it 'returns comptab shipments file' do
        create(:shipment)
        allow_any_instance_of(Trade::ShipmentsExport).to receive(:public_file_name).and_return('shipments.csv')
        allow(Trade::TradeDataDownloadLogger).to receive(:city_country_from).and_return([ 'Cambridge', 'United Kingdom' ])
        allow(Trade::TradeDataDownloadLogger).to receive(:organization_from).and_return('UNEP-WCMC')
        get :download, params: { filters: { report_type: :comptab } }
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"shipments.csv\"; filename*=UTF-8''shipments.csv")
      end
      it 'logs download information from public interface to the TradeDataDownload model' do
        create(:shipment)
        allow_any_instance_of(Trade::ShipmentsExport).to receive(:public_file_name).and_return('shipments.csv')
        allow(Trade::TradeDataDownloadLogger).to receive(:city_country_from).and_return([ 'Cambridge', 'United Kingdom' ])
        allow(Trade::TradeDataDownloadLogger).to receive(:organization_from).and_return('UNEP-WCMC')
        expect do
          get :download, params: {
            filters: {
              report_type: 'comptab',
              exporters_ids: [ '40' ],
              time_range_start: '1975',
              time_range_end: '2000'
            }
          }
        end.to change(Trade::TradeDataDownload, :count).by(1)
      end
    end
    context 'when shipments cannot be retrieved' do
      before(:each) do
        allow_any_instance_of(Trade::ShipmentsExport).to receive(:export).and_return(false)
      end
      it 'redirects to home page' do
        get :download, params: { filters: { report_type: :comptab } }
        expect(response).to redirect_to(cites_trade_root_url)
      end
    end
  end
end
