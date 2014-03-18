require 'spec_helper'

describe Trade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should return all shipments" do
      get :index, format: :json
      response.body.should have_json_size(6).at_path('shipments')
    end
    it "should return genus & species shipments when searching by genus" do
      get :index, taxon_concepts_ids: [@animal_genus.id], format: :json
      response.body.should have_json_size(2).at_path('shipments')
    end
 end

end