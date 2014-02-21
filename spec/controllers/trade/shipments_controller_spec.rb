require 'spec_helper'

describe Trade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    before(:each) do
      cites_eu
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @completed_aru = build(:annual_report_upload)
      @completed_aru.save(:validate => false)
      @completed_aru.submit
    end
    it "should return all shipments" do
      get :index, format: :json
      response.body.should have_json_size(4).at_path('shipments')
    end
 end

end