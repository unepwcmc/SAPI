require 'spec_helper'

describe CitesTrade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    it "should return all comptab shipments" do
      get :index, format: :json
      response.body.should have_json_size(6).at_path('shipment_comptab_export/rows')
    end
    it "should return all gross_exports shipments" do
      get :index, filters: {
        report_type: 'gross_exports',
        time_range_start: 2012,
        time_range_end: 2013,
      }, format: :json
      response.body.should have_json_size(4).at_path('shipment_gross_net_export/rows')
    end
  end

end