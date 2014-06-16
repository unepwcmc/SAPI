require 'spec_helper'

describe Trade::ShipmentsController do
  login_admin

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

    it "should return 1 shipment when searching for reporter_type I" do
      get :index, time_range_start: @shipment1.year, time_range_end: @shipment2.year,
        reporter_type: "E", exporters_ids: [@portugal.id.to_s], format: :json
      response.body.should have_json_size(1).at_path('shipments')
    end
  end

  describe "DELETE destroy_batch" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should delete 1 shipment" do
      post :destroy_batch, {
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'E',
        exporters_ids: [@portugal.id.to_s, @argentina.id.to_s],
        importers_ids: [@portugal.id.to_s, @argentina.id.to_s]}
      Trade::Shipment.count.should == 5
    end
    it "should delete 4 shipment" do
      post :destroy_batch, {
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'I',
        exporters_ids: [@portugal.id.to_s, @argentina.id.to_s],
        importers_ids: [@portugal.id.to_s, @argentina.id.to_s]}
      Trade::Shipment.count.should == 1
    end

    it "should delete 1 shipments" do
      post :destroy_batch, importers_ids: [@argentina.id.to_s]
      Trade::Shipment.count.should == 5
    end

    it "should delete 1 shipments" do
      post :destroy_batch, exporters_ids: [@portugal.id.to_s]
      Trade::Shipment.count.should == 5
    end

    it "should delete all shipments" do
      post :destroy_batch, purposes_ids: [@purpose.id.to_s]
      Trade::Shipment.count.should == 0
    end

    it "shouldn't delete any shipments" do
      post :destroy_batch, purpose_blank: "true"
      Trade::Shipment.count.should == 6
    end

    it "should delete 1 shipment" do
      post :destroy_batch, sources_ids: [@source.id.to_s]
      Trade::Shipment.count.should == 5
    end

    it "should delete 3 shipment" do
      post :destroy_batch, sources_ids: [@source_wild.id.to_s]
      Trade::Shipment.count.should == 3
    end

    it "should delete 0 shipments" do
      post :destroy_batch, sources_ids: [@source_wild.id.to_s],
        reporter_type: 'E'
      Trade::Shipment.count.should == 6
    end

    it "should delete 4 shipments" do
      post :destroy_batch, sources_ids: [@source_wild.id.to_s],
        reporter_type: 'I', source_blank: "true"
      Trade::Shipment.count.should == 2

    end
  end

  describe "DELETE destroy" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should delete 1 shipment" do
      delete :destroy, id: @shipment1.id
      Trade::Shipment.where(id: @shipment1.id).should be_empty
    end
  end
end
