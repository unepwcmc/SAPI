require 'spec_helper'

describe Trade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    it "should return all shipments" do
      get :index, format: :json
      response.body.should have_json_size(4).at_path('shipments')
    end
 end

end